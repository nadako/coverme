@:analyzer(ignore)
@:build(coverme.Instrument.build())
class Main {
    static var a = 5;

    function f() {
        trace("hi");
        {
        };
        trace("oh");
    }

    static function main() {
        trace("Hi!");

        var v = {};

        function f() {}

        trace(if (a > 0) Main.a else 0);
        while (a > 10) {
            if (a > 5) {
                trace(if (a > 10) "oh no!" else "huh");
                trace(a < 10 ? "hey!" : "bloh");
                throw false;
            }
        }

        do trace("HI") while (false);
        trace("Bye!");

        var coverage = coverme.Logger.getCoverage();

        trace("Missing branches:");
        for (branch in coverage.branches) {
            if (branch.result.trueCount == 0 || branch.result.falseCount == 0)
                trace(branch.pos);
        }

        trace("Missing statements:");
        for (statement in coverage.statements) {
            if (statement.result == 0)
                trace(statement.pos);
        }
    }
}
