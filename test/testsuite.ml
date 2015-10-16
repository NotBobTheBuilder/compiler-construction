open Compiler
open Js
open List
open Printf

let tests = [
  ("1+a;", Compiler.Parse [Js.Expr (Js.Add (Js.Number 1, Js.Ident "a"))]);
  ("1++a;", Compiler.ParseError "Line 1, Column 3");
  ("1+a+b+c+d;", Compiler.Parse [Js.Expr
    (Js.Add
      (Js.Add
        (Js.Add
          (Js.Add (Js.Number 1, Js.Ident "a"
          ), Js.Ident "b"
        ), Js.Ident "c"
      ), Js.Ident "d"
    ))
  ]);
  ("1+a/2;", Compiler.Parse [Js.Expr (Js.Add (Js.Number 1, Js.Div(Js.Ident "a", Js.Number 2)))]);
  ("a*foobar;", Compiler.Parse [Js.Expr (Js.Mul (Js.Ident "a", Js.Ident "foobar"))]);
  ("function add(a, b) { a + b; };", Compiler.Parse [Js.Expr (
    Js.Function (
      Some "add",
      ["a"; "b"],
      [Js.Expr (Js.Add (Js.Ident "a", Js.Ident "b"))]
    ))]
  );
  ("var mul = function (a, b) { return a * b; };", Compiler.Parse [
    Js.Assign ("mul",
      Js.Function(
      None,
      ["a"; "b"],
      [Js.Return (Js.Mul (Js.Ident "a", Js.Ident "b"))]
    ))]
  );
  ("var square = function square (a) { return mul(a); };", Compiler.Parse [
    Js.Assign ("square",
      Js.Function(
        Some "square",
        ["a"],
        [Js.Return (Js.Call ("mul", [Js.Ident "a"]))]
    ))]
  )
]

let passed (s, f, e) = (s + 1, f, e)

let failed (s, f, e) got not =
  (print_endline ("Failed, got:\n" ^ got ^ "\nNOT:\n" ^ not); (s, f + 1, e))

let error (s, f, e) err =
  ((print_endline ("Error: " ^ err)); (s, f, e + 1))

let pass_if_equal tally a b =
  if 0 == compare a b then passed tally
  else failed tally a b

let test tally (input, expected) =
  let parsed = (Compiler.eval input) in
  match (parsed, expected) with
  | (Parse p, Parse e) ->
      let pres = Compiler.prettify p in
      let pexp = Compiler.prettify e in
      pass_if_equal tally pres pexp

  | (SyntaxError p, SyntaxError e) -> pass_if_equal tally p e
  | (ParseError p, ParseError e) -> pass_if_equal tally p e

  | (SyntaxError p, Parse e) -> failed tally ("Syntax Error: " ^ p) (Compiler.prettify e)
  | (ParseError p, Parse e) -> failed tally ("Syntax Error: " ^ p) (Compiler.prettify e)

  | (_, _) -> error tally "got a syntax error when I expected a Parse error (or vice versa)"

let testall ts = List.fold_left test (0, 0, 0) ts

let _ =
  match (testall tests) with
    (succs, fails, errs) ->
      Printf.eprintf "%d Successes, %d Failures, %d Errors\n" succs fails errs
