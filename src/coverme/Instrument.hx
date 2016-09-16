package coverme;

#if macro
import haxe.macro.Context;
import haxe.macro.Expr;
import haxe.macro.Type;
using haxe.macro.ExprTools;

private typedef InstrumentContext = {
    var packagePath:Array<String>;
    var moduleName:String;
    var typeName:String;
    var currentField:Null<Field>;
}

class Instrument {
    static var coverage = new Coverage();
    static var context:InstrumentContext;
    static var nextFieldId = 0;
    static var nextStatementId = 0;
    static var nextBranchId = 0;
    static var onGenerateRegistered = false;

    static function build():Array<Field> {
        context = createInstrumentContext(Context.getLocalType());
        getCurrentType(); // register type for coverage

        var fields = Context.getBuildFields();
        for (field in fields) {
            context.currentField = field;
            instrumentField(field);
            // trace(new haxe.macro.Printer().printField(field));
        }

        if (!onGenerateRegistered) {
            onGenerateRegistered = true;
            Context.onGenerate(function(_) {
                haxe.Serializer.USE_CACHE = true;
                var data = haxe.Serializer.run(coverage);
                Context.addResource(Coverage.RESOURCE_NAME, haxe.io.Bytes.ofString(data));
            });
        }

        return fields;
    }

    static function createInstrumentContext(type:Type):InstrumentContext {
        var pack, name, module, pos, isPrivate;
        switch (Context.getLocalType()) {
            case TInst(_.get() => cl, _):
                switch (cl.kind) {
                    case KAbstractImpl(_.get() => ab):
                        pack = ab.pack;
                        name = ab.name;
                        module = ab.module;
                        pos = ab.pos;
                        isPrivate = ab.isPrivate;
                    default:
                        pack = cl.pack;
                        name = cl.name;
                        module = cl.module;
                        pos = cl.pos;
                        isPrivate = cl.isPrivate;
                }
            default:
                throw false; // this should NOT happen
        }

        if (isPrivate) // private classes are placed within an inner module
            pack.pop();

        var moduleParts = module.split(".");
        var moduleName = moduleParts.pop();

        var modulePackStr = moduleParts.join(".");
        var packStr = pack.join(".");
        if (modulePackStr != packStr) // this should NOT happen unless I forgot something
            throw new Error('Module package ($modulePackStr) is not equal to type package ($packStr)', pos);

        return {
            packagePath: pack,
            moduleName: moduleName,
            typeName: name,
            currentField: null
        };
    }

    static function instrumentField(field:Field) {
        switch (field.kind) {
            case FFun(fun) if (fun.expr != null):
                fun.expr = instrumentExpr(blockExpr(fun.expr));
                fun.expr = instrumentFieldExpr(fun.expr);
            case FVar(type, expr) if (expr != null):
                expr = instrumentExpr(blockValueExpr(expr));
                expr = instrumentFieldExpr(expr);
                field.kind = FVar(type, expr);
            case FProp(get, set, type, expr) if (expr != null):
                expr = instrumentExpr(blockValueExpr(expr));
                expr = instrumentFieldExpr(expr);
                field.kind = FProp(get, set, type, expr);
            default:
        }
    }

    static function instrumentFieldExpr(expr:Expr):Expr {
        return {
            expr: EBlock([createFieldLog(), expr]),
            pos: expr.pos,
        }
    }

    static function mkBlock(expr:Expr):Expr {
        return {expr: EBlock([expr]), pos: expr.pos};
    }

    static function blockValueExpr(expr:Expr):Expr {
        return switch (expr.expr) {
            case EBlock([]): mkBlock(expr); // this is not an "empty block", it's a empty object declaration.
            case EBlock(_): expr;
            default: mkBlock(expr);
        }
    }

    static function blockExpr(expr:Expr):Expr {
        return switch (expr.expr) {
            case EBlock(_): expr;
            default: mkBlock(expr);
        }
    }

    static function instrumentExpr(expr:Expr):Expr {
        // TODO: add all possible exprs here, creating blocks for all sub-exprs
        return switch (expr.expr) {
            case EBlock(exprs):
                var instrumentedExprs = [];
                for (e in exprs) {
                    instrumentedExprs.push(createStatementLog(e));
                    instrumentedExprs.push(instrumentExpr(e));
                }
                {expr: EBlock(instrumentedExprs), pos: expr.pos};

            case EFor(it, e):
                it = instrumentExpr(it);
                e = instrumentExpr(blockExpr(e));
                {expr: EFor(it, e), pos: expr.pos};

            case EWhile(econd, e, normal):
                econd = createBranchLog(instrumentExpr(econd));
                e = instrumentExpr(blockExpr(e));
                {expr: EWhile(econd, e, normal), pos: expr.pos};

            case EIf(cond, eif, eelse):
                cond = createBranchLog(instrumentExpr(cond));
                eif = instrumentExpr(blockExpr(eif));
                if (eelse != null)
                    eelse = instrumentExpr(blockExpr(eelse));
                {expr: EIf(cond, eif, eelse), pos: expr.pos};

            case ETernary(cond, eif, eelse):
                cond = createBranchLog(instrumentExpr(cond));
                eif = instrumentExpr(blockExpr(eif));
                eelse = instrumentExpr(blockExpr(eelse));
                {expr: ETernary(cond, eif, eelse), pos: expr.pos};

            default:
                expr.map(instrumentExpr);
        }
    }

    static function getCurrentType():coverme.ModuleType {
        var pack = coverage.findPackage(context.packagePath);
        if (pack == null) {
            pack = new coverme.Package(context.packagePath);
            coverage.packages.push(pack);
        }

        var module = pack.findModule(context.moduleName);
        if (module == null) {
            module = new coverme.Module(pack, context.moduleName);
            pack.modules.push(module);
        }

        var type = module.findType(context.typeName);
        if (type == null) {
            type = new coverme.ModuleType(module, context.typeName);
            module.types.push(type);
        }

        return type;
    }

    static function getCurrentField():coverme.Field {
        var type = getCurrentType();

        var field = type.findField(context.currentField.name);
        if (field == null) {
            field = new coverme.Field(type, context.currentField.name, coverme.Position.fromPos(Context.getPosInfos(context.currentField.pos)));
            type.fields.push(field);
        }

        return field;
    }

    static function createFieldLog():Expr {
        var id = nextFieldId++;
        coverage.fields[id] = getCurrentField();
        return macro coverme.Logger.instance.logField($v{id});
    }

    static function createStatementLog(expr:Expr):Expr {
        var id = nextStatementId++;

        var field = getCurrentField();
        var statement = new Statement(field, coverme.Position.fromPos(Context.getPosInfos(expr.pos)));
        coverage.statements[id] = statement;
        field.statements.push(statement);

        return macro coverme.Logger.instance.logStatement($v{id});
    }

    static function createBranchLog(expr:Expr):Expr {
        var id = nextBranchId++;

        var field = getCurrentField();
        var branch = new Branch(field, coverme.Position.fromPos(Context.getPosInfos(expr.pos)));
        coverage.branches[id] = branch;
        field.branches.push(branch);

        return macro coverme.Logger.instance.logBranch($v{id}, $expr);
    }
}
#end
