package coverme;

class Position {
    public var file(default,null):String;
    public var min(default,null):Int;
    public var max(default,null):Int;

    public function new(file:String, min:Int, max:Int) {
        this.file = file;
        this.min = min;
        this.max = max;
    }

    public static inline function fromPos(pos):Position {
        return new Position(pos.file, pos.min, pos.max);
    }
}
