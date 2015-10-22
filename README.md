Work for my Compiler Construction module @ UoB

[![Build Status](https://img.shields.io/travis/NotBobTheBuilder/compiler-construction.svg)](https://travis-ci.org/NotBobTheBuilder/compiler-construction)

Running
=======

Run `make` to install dependencies and generate `./main.native`, the main source file. From there you can run `./main.native` and manually enter programs, or you can pipe programs into it with `cat file.js | ./main.native`.

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
