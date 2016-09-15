package coverme;

class BranchResult {
    public var trueCount(default,null):Int;
    public var falseCount(default,null):Int;

    public function new() {
        trueCount = falseCount = 0;
    }

    public function report(value:Bool) {
        if (value)
            trueCount++;
        else
            falseCount++;
    }
}
