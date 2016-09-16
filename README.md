# CoverMe

This library provides code coverage for Haxe projects.

**STATUS**: PRE-ALPHA (very much work in progress, trying out stuff, NOT ready for real world)

It is heavily inspired by [mcover](https://github.com/massiveinteractive/mcover), however
it's written from scratch in modern Haxe for modern Haxe.

Not much more to say right now, since it's in very early stage of development.

Here's something to play with though: https://nadako.github.io/coverme/

## Usage

Don't use it, it's not ready. I'll update the README when it's ready for public usage. :)

## Implementation

It's implemented as the build macro that instruments Haxe expressions by adding additional
logging function call to each "statement" and "branch", e.g. this:

```haxe
class MyClass {
    static function myFunction(a:Int) {
        if (a == 10) {
            trace("Ten!");
        } else {
            trace("Not ten!");
        }
    }
}
```

becomes this (JavaScript output):

```js
MyClass.myFunction = function(a) {
    coverme_Logger.logStatement(0);
    if(coverme_Logger.logBranch(1,a == 10)) {
        coverme_Logger.logStatement(2);
        console.log("Ten!");
    } else {
        coverme_Logger.logStatement(3);
        console.log("Not ten!");
    }
};
```

As you can see, there are `logStatement` calls added before each statement in a block.
The numbers are identifiers of a statement, created at compile-time. And then there's a
mapping from these identifiers to objects containing information about statements, such
as file and position (also created at compile-time).

When you run the code, injected `logStatement`s will increase execution counters
of their corresponding statements. The `logBranch` is almost the same,
but has two counters (for `true` and `false` evaluation results).

After running the code in question, we have all counters there and we can analyze the results
and report statements and branches that wasn't evaluated once in a nice HTML page:

![](http://i.imgur.com/vBEIZXk.gif)

## Obligatory meme

![](http://weknowmemes.com/wp-content/uploads/2013/01/cover-me-comic.jpg)