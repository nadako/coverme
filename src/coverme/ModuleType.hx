package coverme;

class ModuleType {
    public var module(default,null):Module;
    public var name(default,null):String;
    public var pos(default,null):Position;
    public var fields(default,null):Array<Field>;
    public var stats(default,null):Stats;

    public function new(module:Module, name:String, pos:Position) {
        this.module = module;
        this.name = name;
        this.pos = pos;
        fields = [];
        stats = new Stats();
    }

    public function findField(name:String):Null<Field> {
        for (field in fields) {
            if (field.name == name)
                return field;
        }
        return null;
    }

    public function initStats() {
        for (field in fields) {
            field.initStats();
            stats.statementsCovered += field.stats.statementsCovered;
            stats.branchesCovered += field.stats.branchesCovered;
            if (field.count > 0)
                stats.fieldsCovered++;
        }
    }
}
