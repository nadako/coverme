// Generated by Haxe 3.3.0 (git build development @ e215eb3)
(function () { "use strict";
function $extend(from, fields) {
	function Inherit() {} Inherit.prototype = from; var proto = new Inherit();
	for (var name in fields) proto[name] = fields[name];
	if( fields.toString !== Object.prototype.toString ) proto.toString = fields.toString;
	return proto;
}
var Main = function() { };
Main.main = function() {
	coverme_Logger.logStatement(0);
	console.log("Hi!");
	coverme_Logger.logStatement(1);
	var v = { };
	coverme_Logger.logStatement(2);
	console.log(coverme_Logger.logBranch(3,Main.a > 0)?Main.a:0);
	coverme_Logger.logStatement(4);
	while(coverme_Logger.logBranch(5,Main.a > 10)) {
		coverme_Logger.logStatement(6);
		if(coverme_Logger.logBranch(7,Main.a > 5)) {
			coverme_Logger.logStatement(8);
			console.log(coverme_Logger.logBranch(9,Main.a > 10)?"oh no!":"huh");
			coverme_Logger.logStatement(10);
			console.log(coverme_Logger.logBranch(11,Main.a < 10)?"hey!":"bloh");
			coverme_Logger.logStatement(12);
			throw new js__$Boot_HaxeError(false);
		}
	}
	coverme_Logger.logStatement(13);
	do {
		coverme_Logger.logStatement(15);
		console.log("HI");
	} while(coverme_Logger.logBranch(14,false));
	coverme_Logger.logStatement(16);
	console.log("Bye!");
};
var coverme_Logger = function() { };
coverme_Logger.logStatement = function(id) {
};
coverme_Logger.logBranch = function(id,value) {
	return value;
};
var js__$Boot_HaxeError = function(val) {
	Error.call(this);
	this.val = val;
	this.message = String(val);
	if(Error.captureStackTrace) {
		Error.captureStackTrace(this,js__$Boot_HaxeError);
	}
};
js__$Boot_HaxeError.wrap = function(val) {
	if((val instanceof Error)) {
		return val;
	} else {
		return new js__$Boot_HaxeError(val);
	}
};
js__$Boot_HaxeError.__super__ = Error;
js__$Boot_HaxeError.prototype = $extend(Error.prototype,{
});
Main.a = 5;
Main.main();
})();