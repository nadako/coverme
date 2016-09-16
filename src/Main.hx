@:build(coverme.Instrument.build())
class C {
    function new () {}
}

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

class Main {
    static function main() {
        var c = new CoverTest();
        // var c = new CoverTest();
        c.f(15);

        var i:pack.MyInt = 10;
        i.times(function() {});

        // ---

        var coverage = coverme.Logger.instance.getCoverage();
        HtmlReport.report(coverage, "coverage");
    }
}
