@:build(coverme.Instrument.build())
class CoverTest {
    var a = {};
    var b = {
        {};
    };
    var c(default,never) = {
        if (Math.random() > 0.5 ? false : true)
            trace("hi");
        5;
    };

    public function new() {}

    public function f(a:Int) {
        if (a > 10) {
            trace("hi!");
            return;
            trace("unreachable");
        } else {
            trace("bye!");
        }
        trace("still here");
    }

    public function f2(v:Int):String {
        return switch (v) {
            case 1: "one";
            case 2: "two";
            default: "other";
        }
    }
}

@:build(coverme.Instrument.build())
abstract MyInt(Int) from Int {
    public inline function times(fn:Void->Void) {
        for (_ in 0...this)
            fn();
    }
}

class Main {
    static function main() {
        var c = new CoverTest();
        // var c = new CoverTest();
        c.f(15);

        var i:MyInt = 5;
        i.times(function() {});

        // ---

        var coverage = coverme.Logger.instance.getCoverage();
        HtmlReport.report(coverage, "bin/index.html");
    }
}
