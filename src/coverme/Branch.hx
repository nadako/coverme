package coverme;

class Branch {
    public var field(default,null):Field;
    public var pos(default,null):Position;
    public var trueCount:Int;
    public var falseCount:Int;

    public function new(field:Field, pos:Position) {
        this.field = field;
        this.pos = pos;
        trueCount = 0;
        falseCount = 0;
    }
}
