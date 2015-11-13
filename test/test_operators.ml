open Utils

let tests = [
  parse_ok "1+a;";
  parse_pe "1++a;";

  parse_ok "1+a+b+c+d;";
  parse_ok "1+a*b/c%d;";
  parse_pe "1+a**b/c%d;";

  parse_pe "1+a+b+c+d/;";
  parse_ok "1+1+1+1+1+1;";

  parse_ok "1                                            +a+b+c+d;";
  parse_pe "1 1+2;";

  parse_ok "1+a/2;";
  parse_ok "a*foobar;";

  parse_ok "1==1;"
]
