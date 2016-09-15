package coverme;

class Logger {
    static var branchResults = new Map<Int,BranchResult>();
    static var statementResults = new Map<Int,Int>();

    public static function logStatement(id:Int) {
        var count = statementResults[id];
        if (count == null)
            count = 1;
        else
            count++;
        statementResults[id] = count;
    }

    public static function logBranch(id:Int, value:Bool):Bool {
        var result = branchResults[id];
        if (result == null) {
            result = new BranchResult();
            branchResults[id] = result;
        }
        result.report(value);
        return value;
    }
}
