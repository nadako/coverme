package coverme;

class Field {
    public var type(default,null):ModuleType;
    public var name(default,null):String;
    public var pos(default,null):Position;
    public var statements(default,null):Array<Statement>;
    public var branches(default,null):Array<Branch>;
    public var stats(default,null):Stats;
    public var count:Int;

    public function new(type:ModuleType, name:String, pos:Position) {
        this.type = type;
        this.name = name;
        this.pos = pos;
        statements = [];
        branches = [];
        count = 0;
        stats = new Stats();
    }

    public function initStats() {
        for (statement in statements) {
            if (statement.count > 0)
                stats.statementsCovered++;
        }
        for (branch in branches) {
            if (branch.trueCount > 0 && branch.falseCount > 0)
                stats.branchesCovered++;
        }
    }
}
