package coverme;

class BranchResult {
    public var trueCount(default,null):Int;
    public var falseCount(default,null):Int;

    public function new() {
        trueCount = 0;
        falseCount = 0;
    }

    public inline function report(value:Bool) {
        if (value)
            trueCount++;
        else
            falseCount++;
    }
}
