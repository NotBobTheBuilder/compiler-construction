open Utils

let tests = [
  run_js "1;" 1;
  run_js "1+2;" 3;
  run_js "10+10+10+10+10;" 50;
  run_js "100*2;" 200;
  run_js "100*2+1;" 201;
  run_js "var a=4; var b=5;var c=6;a+b*c;" 34;
]
