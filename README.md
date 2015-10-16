Work for my Compiler Construction module @ UoB

![Build Status](https://img.shields.io/travis/NotBobTheBuilder/compiler-construction.svg)

Running
=======

Run `make` to install dependencies and generate `./main.native`, the main source file. From there you can run `./main.native` and manually enter programs, or you can pipe programs into it with `cat file.js | ./main.native`.

Running Tests
=============

`make test` builds and runs the tests. for some reason, they only seem to work on ocaml4.0.2 and not earlier (investigating).

What's implemented
==================

- Basic JavaScript assignment & operations
- Function definitions
- Function expressions
- Function calls

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
