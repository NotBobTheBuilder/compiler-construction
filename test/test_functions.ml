open Utils

let tests = [
  parse_ok "function add(a, b) { a + b; };";
  parse_ok "function (a, b) { a + b; };";

  parse_pe "function a, b { a + b; };";
  parse_pe "function (a, b) a + b; };";

  parse_ok "var mul = function (a, b) { return a * b; };";
  parse_ok "var square = function square (a) { return mul(a); };";

  parse_pe "function (a, b) { (return a) * b; };";
]
