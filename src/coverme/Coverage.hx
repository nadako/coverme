package coverme;

class Coverage {
    public var branches(default,null):Map<Int,Branch>;
    public var statements(default,null):Map<Int,Statement>;

    public function new() {
        branches = new Map();
        statements = new Map();
    }

    public function setResults(branchResults:Map<Int,BranchResult>, statementResults:Map<Int,Int>) {
        for (id in branches.keys()) {
            var result = branchResults[id];
            if (result == null)
                result = new BranchResult();
            branches[id].setResult(result);
        }

        for (id in statements.keys()) {
            var result = statementResults[id];
            if (result == null)
                result = 0;
            statements[id].setResult(result);
        }
    }
}
