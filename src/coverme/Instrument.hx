package coverme;

#if macro
import haxe.macro.Context;
import haxe.macro.Expr;
using haxe.macro.ExprTools;

class Instrument {
    static var nextId = 0;

    static function build():Array<Field> {
        var fields = Context.getBuildFields();
        for (field in fields) {
            instrumentField(field);
        }
        return fields;
    }

    static function instrumentField(field:Field) {
        switch (field.kind) {
            case FFun(fun) if (fun.expr != null):
                fun.expr = switch (fun.expr.expr) {
                    case EBlock([]): // TODO: what about empty inner functions?
                        {expr: EBlock([createStatementLog()]), pos: fun.expr.pos};
                    default:
                        instrumentExpr(blockExpr(fun.expr));
                };
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
                expr;

            case EBlock(exprs):
                var instrumentedExprs = [];
                for (expr in exprs) {
                    if (isStatement(expr))
                        instrumentedExprs.push(createStatementLog());
                    instrumentedExprs.push(instrumentExpr(expr));
                }
                {expr: EBlock(instrumentedExprs), pos: expr.pos};

            default:
                expr.map(instrumentExpr);
        }
    }

    static function isStatement(e:Expr):Bool {
        return switch (e.expr) {
            case EConst(_) | EField(_, _): false;
            default: true;
        }
    }

    static function blockExpr(expr:Expr):Expr {
        return switch (expr.expr) {
            case EBlock(_): expr;
            default: {expr: EBlock([expr]), pos: expr.pos};
        }
    }

    static function createStatementLog():Expr {
        var id = nextId++;
        return macro coverme.Logger.logStatement($v{id});
    }

    static function createBranchLog(cond:Expr):Expr {
        var id = nextId++;
        return macro coverme.Logger.logBranch($v{id}, $cond);
    }
}
#end
