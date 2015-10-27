open Utils

let tests = [
  (* Being smart with constant operations *)
  parse_eq "1+1+1+1+1+1;" "6;";
  parse_eq "1+2*6*5;"     "61;";

  parse_eq "a(5*2+1);"    "a(11);";

  parse_eq "2*4-2+a;"     "6+a;";

  parse_eq "return 20*5;" "return 100;";

  (* Being smart with branch refactoring *)
  (* Deleting impossible branches *)
  parse_eq  "if (0) { doSomething(); }"
            "";

  (* Inlining certain ones *)
  parse_eq  "if (1) { doSomething(); }"
            "doSomething();";

  (* Preserving unclear ones *)
  parse_eq  "if (a) { doSomething(); }"
            "if (a) { doSomething(); }";

  parse_eq  "while (0) { doSomething(); }"
            "";

  parse_eq  "while (1) { doSomething(); }"
            "while (1) { doSomething(); }";

  (* Selecting the right branch in a constant if-else block *)
  parse_eq  "if (1) { a(); } else { b(); }"
            "a();";

  parse_eq  "if (0) { a(); } else { b(); }"
            "b();";

  parse_eq  "if (x) { a(); } else { b(); }"
            "if (x) { a(); } else { b(); }";

  (* Drop dead code after return statements *)
  parse_eq  "function () { return 1; 1+2; a(); };"
            "function () { return 1; };";

  parse_eq  "function () { if (a) { return 1; 1+2; a(); } };"
            "function () { if (a) { return 1; } };";
]
