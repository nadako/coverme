package coverme;

class Logger {
    @:pure(false)
    public static function logStatement(id:Int) {}

    @:pure(false)
    public static function logBranch(id:Int, value:Bool) return value;
}
