package coverme;

class ModuleType {
    public var module(default,null):Module;
    public var name(default,null):String;
    public var fields(default,null):Array<Field>;

    public function new(module:Module, name:String) {
        this.module = module;
        this.name = name;
        fields = [];
    }

    public function findField(name:String):Null<Field> {
        for (field in fields) {
            if (field.name == name)
                return field;
        }
        return null;
    }
}
