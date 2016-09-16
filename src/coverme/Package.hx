package coverme;

class Package {
    public var path(default,null):Array<String>;
    public var modules(default,null):Array<Module>;
    public var stats(default,null):Stats;

    public function new(path:Array<String>) {
        this.path = path;
        modules = [];
        stats = new Stats();
    }

    public function findModule(name:String):Null<Module> {
        for (module in modules) {
            if (module.name == name)
                return module;
        }
        return null;
    }

    public function initStats() {
        for (module in modules) {
            module.initStats();
            stats.statementsCovered += module.stats.statementsCovered;
            stats.branchesCovered += module.stats.branchesCovered;
            stats.fieldsCovered += module.stats.fieldsCovered;
            stats.typesCovered += module.stats.typesCovered;
            if (module.stats.typesCovered > 0)
                stats.modulesCovered++;
        }
    }
}
