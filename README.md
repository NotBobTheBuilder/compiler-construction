Work for my Compiler Construction module @ UoB

[![Build Status](https://img.shields.io/travis/NotBobTheBuilder/compiler-construction.svg)](https://travis-ci.org/NotBobTheBuilder/compiler-construction)

Running
=======

Run `make` to install dependencies and generate `./main.native`, the main source file. From there you can run `./main.native` and manually enter programs, or you can pipe programs into it with `cat file.js | ./main.native`.

Run `./main.native -o` to enable optimisations, which will refactor the AST of the code you've pass in. Refer to `--help` for details on this and newer features

Running Tests
=============

`make test` builds and runs the tests. You can also see some results on the [Travis CI Build Matrix](https://travis-ci.org/NotBobTheBuilder/compiler-construction), which runs the tests on Mac and Linux across various common Ocaml versions.

What's implemented
==================

- Basic JavaScript assignment & operations
- Function definitions
- Function expressions
- Function calls
- Flow Control
- Comparisons
- Optimisations

A sample program:

    var a = 1;
    var b = 2;
    function add(x, y) {
      return x + y;
    };
    var mul = function(x, y) {
      return x * y;
    };
    var square = function(x) {
      return mul(x, x);
    };
    var imperativeCount = function(n) {
      if (n % 2 == 0) {
        a();
      } else {
        b();
      }
      while (n > 0) {
        alert(n);
        n = n - 1;
      }
    }

# Assembly Compilation

## TL;DR: Run `make sample` to build and run the file `something.js`

Currently compiles all expressions and some (but not all) variables - something weird going on with the stack.

- Scopes are now associated with functions and the program. A scope is currently a map of variable names to optionally inferred values
  - The size of the map bindings list determines how much space is allocated on the stack.
- Scopes are built during the optimiser stage and are only currently expanded by function parameters and `var x=..`
- Expression codegen is quite simple really, see `Asm.ml`
- Stack variables fully work to any size
- Constant propagation implemented
- if, if/else, and while loops (including constant-based branch elimination)

## Benchmarks

| Node     | Mine     | Program                                                                                       |
|----------|----------|-----------------------------------------------------------------------------------------------|
| 0m0.080s | 0m0.004s | `function fifty(a) { if (a < 50) { return fifty(a+1); } else { return a; } }; fifty(1);`  |
| 0m0.076s | 0m0.004s | `var a = 0; while (a<5000) {a=a+1;} a;`                                                       |
| 0m0.076s | 0m0.005s | lots of addition                                                                              |
