package coverme;

class Module {
    public var pack(default,null):Package;
    public var name(default,null):String;
    public var types(default,null):Array<ModuleType>;

    public function new(pack:Package, name:String) {
        this.pack = pack;
        this.name = name;
        types = [];
    }

    public function findType(name:String):Null<ModuleType> {
        for (type in types) {
            if (type.name == name)
                return type;
        }
        return null;
    }
}
