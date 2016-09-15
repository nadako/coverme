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

@:build(coverme.Instrument.build())
abstract MyInt(Int) from Int {
    public inline function times(f:Void->Void) {
        for (_ in 0...this) {
            f();
        }
    }
}

class Main {
    static function main() {
        var c = new CoverTest();
        c.f(true);
        // c.f(false);

        var i:MyInt = 5;
        i.times(function() {});

        // ---

        var coverage = coverme.Logger.getCoverage();
        HtmlReport.report(coverage, "coverage.html");
    }
}
