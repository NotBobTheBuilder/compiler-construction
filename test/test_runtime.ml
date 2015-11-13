open Utils

let tests = [
  run_js "1;" 1;
  run_js "1+2;" 3;
  run_js "10+10+10+10+10;" 50;
  run_js "100*2;" 200;
  run_js "100*2+1;" 201;
  run_js "var a=4; var b=5;var c=6;a+b*c;" 34;

  run_js_no_opt "var a = 0; if (a) {a=2;} a;" 0;
  run_js_no_opt "var a = 100; if (a) {a=2;} a;" 2;

  run_js_no_opt "var a = 0; if (a) {a=2;} else {a=3;} a;" 3;
  run_js_no_opt "var a = 1; if (a) {a=2;} else {a=3;} a;" 2;

  run_js_no_opt "var a = 5; while (a) {a=a-1;} a;" 0;
]
