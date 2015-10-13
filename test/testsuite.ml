open Compiler
open Js
open List
open Printf

let tests = [
  ("1+a;", [Js.Expr (Js.Add (Js.Number 1, Js.Ident "a"))]);
  ("1+a+b+c+d;", [Js.Expr
    (Js.Add
      (Js.Add
        (Js.Add
          (Js.Add (Js.Number 1, Js.Ident "a"
          ), Js.Ident "b"
        ), Js.Ident "c"
      ), Js.Ident "d"
    ))
  ]);
  ("1+a/2;", [Js.Expr (Js.Add (Js.Number 1, Js.Div(Js.Ident "a", Js.Number 2)))]);
  ("a*foobar;", [Js.Expr (Js.Mul (Js.Ident "a", Js.Ident "foobar"))]);
  ("function add(a, b) { a + b; };", [Js.Expr (
    Js.Function (
      Some "add",
      ["a"; "b"],
      [Js.Expr (Js.Add (Js.Ident "a", Js.Ident "b"))]
    ))]
  )
]

let test (succs, fails, errs) (input, exp) =
  let _ = print_string ("Testing: " ^ input ^ "\nStatus: ") in
    try
      let res = (Compiler.eval input) in
      let pres = Compiler.prettify res in
      let pexp = Compiler.prettify exp in
        if 0 == compare pres pexp then
          let _ = print_endline "Passed" in (succs + 1, fails, errs)
        else
          let _ = print_endline ("Failed, got:\n" ^ pres ^ "\n NOT:\n" ^ pexp) in (succs, fails + 1, errs)
    with
      _ -> let _ = print_endline "Error" in (succs, fails, errs + 1)

let _ =
  match (List.fold_left test (0, 0, 0) tests) with
    (succs, fails, errs) ->
      Printf.eprintf "%d Successes, %d Failures, %d Errors\n" succs fails errs
