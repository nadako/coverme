package pack;

@:build(coverme.Instrument.build())
abstract MyInt(Int) from Int {
    public inline function times(fn:Void->Void) {
        for (_ in 0...this)
            fn();
    }
}
