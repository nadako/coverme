package coverme;

class Module {
    public var pack(default,null):Package;
    public var name(default,null):String;
    public var types(default,null):Array<ModuleType>;
    public var stats(default,null):Stats;

    public function new(pack:Package, name:String) {
        this.pack = pack;
        this.name = name;
        types = [];
        stats = new Stats();
    }

    public function findType(name:String):Null<ModuleType> {
        for (type in types) {
            if (type.name == name)
                return type;
        }
        return null;
    }

    public function initStats() {
        for (type in types) {
            type.initStats();
            stats.statementsCovered += type.stats.statementsCovered;
            stats.branchesCovered += type.stats.branchesCovered;
            stats.fieldsCovered += type.stats.fieldsCovered;
            if (type.stats.fieldsCovered > 0)
                stats.typesCovered++;
        }
    }
}
