package coverme;

class Statement {
    public var pos(default,null):Position;
    public var result(default,null):Int;

    public function new(pos:Position) {
        this.pos = pos;
    }

    public function setResult(count:Int) {
        result = count;
    }
}
