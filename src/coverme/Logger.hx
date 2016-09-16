package coverme;

class Logger {
    public static var instance(get,null):Logger;
    static function get_instance():Logger {
        if (instance == null) instance = new Logger();
        return instance;
    }

    var fieldResults:Map<Int,Int>;
    var statementResults:Map<Int,Int>;
    var branchResults:Map<Int,BranchResult>;

    function new() {
        fieldResults = new Map();
        statementResults = new Map();
        branchResults = new Map();
    }

    public function getCoverage():Coverage {
        var data = haxe.Resource.getString(Coverage.RESOURCE_NAME);
        var coverage:Coverage = haxe.Unserializer.run(data);
        coverage.setResults(fieldResults, statementResults, branchResults);
        return coverage;
    }

    public function logField(id:Int) {
        var count = fieldResults[id];
        if (count == null)
            count = 1;
        else
            count++;
        fieldResults[id] = count;
    }

    public function logStatement(id:Int) {
        var count = statementResults[id];
        if (count == null)
            count = 1;
        else
            count++;
        statementResults[id] = count;
    }

    public function logBranch(id:Int, value:Bool):Bool {
        var result = branchResults[id];
        if (result == null) {
            result = new BranchResult();
            branchResults[id] = result;
        }
        result.report(value);
        return value;
    }
}
