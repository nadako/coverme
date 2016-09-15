@:build(coverme.Instrument.build())
class Main {
    static var a = 5;

    @:analyzer(ignore)
    static function main() {
        trace("Hi!");

        var v = {};

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
    }
}
