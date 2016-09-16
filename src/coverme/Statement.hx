package coverme;

class Statement {
    public var field(default,null):Field;
    public var pos(default,null):Position;
    public var count:Int;

    public function new(field:Field, pos:Position) {
        this.field = field;
        this.pos = pos;
        count = 0;
    }
}
