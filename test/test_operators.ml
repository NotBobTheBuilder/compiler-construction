open Utils

let tests = [
  parse_ok "1+a;";
  parse_pe "1++a;";

  parse_ok "1+a+b+c+d;";
  parse_ok "1+a/2;";
  parse_ok "a*foobar;";
]
