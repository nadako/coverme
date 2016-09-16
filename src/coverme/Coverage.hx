package coverme;

class Coverage {
    public static inline var RESOURCE_NAME = "coverage";

    public var packages(default,null):Array<Package>;
    public var fields(default,null):Map<Int,Field>;
    public var branches(default,null):Map<Int,Branch>;
    public var statements(default,null):Map<Int,Statement>;

    public function new() {
        packages = [];
        fields = new Map();
        branches = new Map();
        statements = new Map();
    }

    public function findPackage(path:Array<String>):Null<Package> {
        var path = path.join(".");
        for (pack in packages) {
            if (pack.path.join(".") == path)
                return pack;
        }
        return null;
    }

    public function setResults(fieldResults:Map<Int,Int>, statementResults:Map<Int,Int>, branchResults:Map<Int,BranchResult>) {
        for (fieldId in fieldResults.keys())
            fields[fieldId].count = fieldResults[fieldId];

        for (statementId in statementResults.keys())
            statements[statementId].count = statementResults[statementId];

        for (branchId in branchResults.keys()) {
            var result = branchResults[branchId];
            var branch = branches[branchId];
            branch.trueCount = result.trueCount;
            branch.falseCount = result.falseCount;
        }
    }
}
