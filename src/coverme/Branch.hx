package coverme;

class Branch {
    public var pos(default,null):Position;
    public var result(default,null):BranchResult;

    public function new(pos:Position) {
        this.pos = pos;
    }

    public function setResult(result:BranchResult) {
        this.result = result;
    }
}
