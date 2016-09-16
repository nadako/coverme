package coverme;

class Package {
    public var path(default,null):Array<String>;
    public var modules(default,null):Array<Module>;

    public function new(path:Array<String>) {
        this.path = path;
        modules = [];
    }

    public function findModule(name:String):Null<Module> {
        for (module in modules) {
            if (module.name == name)
                return module;
        }
        return null;
    }
}
