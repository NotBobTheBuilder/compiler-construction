open Utils

let tests = [
  parse_ok "function add(a, b) { a + b; };";
  parse_ok "var mul = function (a, b) { return a * b; };";
  parse_ok "var square = function square (a) { return mul(a); };";
]
