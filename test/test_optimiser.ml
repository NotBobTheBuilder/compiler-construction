open Utils

let tests = [
  parse_eq "1+1+1+1+1+1;" "6;";
  parse_eq "1+2*6*5;" "61;";

  parse_eq "a(5*2+1);" "a(11);";

  parse_eq "2*4-2+a;" "6+a;";

  parse_eq "if (0) { doSomething(); }" "";
  parse_eq "if (1) { doSomething(); }" "doSomething();";
  parse_eq "if (a) { doSomething(); }" "if (a) { doSomething(); }";

  parse_eq "while (0) { doSomething(); }" "";
  parse_eq "while (1) { doSomething(); }" "while (1) { doSomething(); }";

  parse_eq "if (1) { a(); } else { b(); }" "a();";
  parse_eq "if (0) { a(); } else { b(); }" "b();";
  parse_eq "if (x) { a(); } else { b(); }" "if (x) { a(); } else { b(); }";
]
