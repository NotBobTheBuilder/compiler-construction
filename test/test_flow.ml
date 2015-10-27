open Utils

let tests = [
  parse_ok "while (a > b) { doSomething(); }";
  parse_ok "if (true) { doSomething(); }";

  parse_pe "while true { doSomething(); }";
  parse_pe "if true { doSomething(); }";

  parse_ok "if (a>b) { alert(1); } else { alert(2); }";
  parse_pe "if (a>b) { alert(1); } { alert(2); }";
  parse_pe "else { alert('b bigger'); }";
]
