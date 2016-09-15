@:build(coverme.Instrument.build())
class CoverTest {
    public function new() {}

    public function f(b:Bool) {
        if (b) {
            trace("a");
            return;
        } else {
            trace("b");
        }

        trace("c");
    }
}

class Main {
    static function main() {
        var c = new CoverTest();
        c.f(true);
        // c.f(false);

        // ---

        var coverage = coverme.Logger.getCoverage();

        trace("Missing branches:");
        for (branch in coverage.branches) {
            if (branch.result.trueCount == 0 || branch.result.falseCount == 0) {
                var missing = [];
                if (branch.result.trueCount == 0)
                    missing.push("true");
                if (branch.result.falseCount == 0)
                    missing.push("false");
                trace(haxe.Json.stringify(branch.pos) + " : " + missing.join(", "));
            }
        }

        trace("Missing statements:");
        for (statement in coverage.statements) {
            if (statement.result == 0)
                trace(haxe.Json.stringify(statement.pos));
        }
    }
}
