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

Currently compiles all expressions and some (but not all) variables - something weird going on with the stack.

- Scopes are now associated with functions and the program. A scopes is curerntly just a list of variable names
  - The size of this list should determine how much space is allocated on the stack.
  - (But that bit of code didn't work so I deleted it, oops)
- Scopes are built during parsing and are only currently expanded by function parameters and `var x=..`
- Expression codegen is quite simple really, see `Asm.ml`
- Variables *sort of* work. Programs with 1 or 2 variables seem to be ok. This is blind luck because the stack is only partially working
  - When I try to allocate memory in the stack for variables I get segfaults
  - So I choose not to and pray instead 
