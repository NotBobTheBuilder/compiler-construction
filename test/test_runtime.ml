open Utils

let tests = [
  run_js "1;" 1;
  run_js "1+2;" 3;
  run_js "10+10+10+10+10;" 50;
  run_js "100*2;" 200;
  run_js "100*2+1;" 201;
  run_js "var a=4; var b=5;var c=6;a+b*c;" 34;


  run_js_no_opt "5==5;" 1;
  run_js_no_opt "5==4;" 0;

  run_js_no_opt "var a = 0; if (a) {a=2;} a;" 0;
  run_js_no_opt "var a = 100; if (a) {a=2;} a;" 2;

  run_js_no_opt "var a = 0; if (a) {a=2;} else {a=3;} a;" 3;
  run_js_no_opt "var a = 1; if (a) {a=2;} else {a=3;} a;" 2;

  run_js_no_opt "var a = 5; while (a) {a=a-1;} a;" 0;

  run_js_no_opt "var a = 5; var b = 5; var c = 1; if (a==b) {c=2;} c;" 2;

  run_js_no_opt "var a = 5; var b = 5; var c = 1; if (a==b) {c=2;} else {c=3;} c;" 2;
  run_js_no_opt "var a = 100; var b = 5; var c = 1; if (a==b) {c=2;} else {c=3;} c;" 3;

  run_js_no_opt "var a = 0; while (a<5) {a=a+1;} a;" 5;

  run_js_no_opt "function abc() { return 2; }; abc();" 2;

  run_js_no_opt "function abc() { }; abc() == undefined;" 1;

  run_js_no_opt "function xyz() { return 4+1; }; var a = xyz() + 1; a;" 6;

  run_js_no_opt "function r1() { return 1; }; function r2() { return r1() + r1(); }; r2();" 2;

  run_js_no_opt "function r1() { var a = 1; return a; }; function r2() { return r1() + r1(); }; r2();" 2;

  run_js_no_opt "function double(a) { return a+a; }; double(1);" 2;

  run_js_no_opt "function add(a,b) { return a + b; }; add(1,2);" 3;

  run_js_no_opt "function fifty(a) { if (a < 50) { return 1 + fifty(a+1); } else { return 1; } }; fifty(1);" 50;

]
