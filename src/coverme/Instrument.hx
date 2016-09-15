package coverme;

#if macro
import haxe.macro.Context;
import haxe.macro.Expr;
using haxe.macro.ExprTools;

class Instrument {
    static var nextId = 0;
    static var functionStack:Array<Function>;
    static var coverage = new Coverage();
    static var onGenerateRegistered = false;

    static function build():Array<Field> {
        var fields = Context.getBuildFields();
        for (field in fields)
            instrumentField(field);

        if (!onGenerateRegistered) {
            onGenerateRegistered = true;
            Context.onGenerate(function(_) {
                var data = haxe.io.Bytes.ofString(haxe.Serializer.run(coverage));
                Context.addResource("coverage", data);
            });
        }

        return fields;
    }

    static function instrumentField(field:Field) {
        switch (field.kind) {
            case FFun(fun) if (fun.expr != null):
                functionStack = [fun];
                fun.expr = instrumentExpr(blockExpr(fun.expr));
                functionStack = null;
            default:
        }
    }

    static function instrumentExpr(expr:Expr):Expr {
        return switch (expr.expr) {
            case EIf(econd, eif, eelse):
                econd = createBranchLog(instrumentExpr(econd));
                eif = instrumentExpr(blockExpr(eif));
                if (eelse != null)
                    eelse = instrumentExpr(blockExpr(eelse));
                {expr: EIf(econd, eif, eelse), pos: expr.pos};

            case ETernary(econd, eif, eelse):
                econd = createBranchLog(instrumentExpr(econd));
                eif = instrumentExpr(blockExpr(eif));
                eelse = instrumentExpr(blockExpr(eelse));
                {expr: ETernary(econd, eif, eelse), pos: expr.pos};

            case EWhile(econd, ebody, normal):
                econd = createBranchLog(instrumentExpr(econd));
                ebody = instrumentExpr(blockExpr(ebody));
                {expr: EWhile(econd, ebody, normal), pos: expr.pos};

            case EBlock([]):
                // we don't care about empty blocks unless it's a function expression
                if (expr == functionStack[functionStack.length - 1].expr)
                    {expr: EBlock([createStatementLog(expr)]), pos: expr.pos};
                else
                    expr;

            case EBlock(exprs):
                var instrumentedExprs = [];
                for (expr in exprs) {
                    if (isStatement(expr))
                        instrumentedExprs.push(createStatementLog(expr));
                    instrumentedExprs.push(instrumentExpr(expr));
                }
                {expr: EBlock(instrumentedExprs), pos: expr.pos};

            case EFunction(name, fun) if (fun.expr != null):
                functionStack.push(fun);
                fun.expr = instrumentExpr(blockExpr(fun.expr));
                functionStack.pop();
                {expr: EFunction(name, fun), pos: expr.pos};

            default:
                expr.map(instrumentExpr);
        }
    }

    static function isStatement(e:Expr):Bool {
        return switch (e.expr) {
            case EConst(_) | EField(_, _) | EFunction(_, _) | EBlock(_): false;
            default: true;
        }
    }

    static function blockExpr(expr:Expr):Expr {
        return switch (expr.expr) {
            case EBlock(_): expr;
            default: {expr: EBlock([expr]), pos: expr.pos};
        }
    }

    static function createStatementLog(expr:Expr):Expr {
        var id = nextId++;
        coverage.statements[id] = new Statement(Context.getPosInfos(expr.pos));
        return macro coverme.Logger.logStatement($v{id});
    }

    static function createBranchLog(cond:Expr):Expr {
        var id = nextId++;
        coverage.branches[id] = new Branch(Context.getPosInfos(cond.pos));
        return macro coverme.Logger.logBranch($v{id}, $cond);
    }
}
#end
