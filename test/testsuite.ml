open Utils
open Compiler
open Js
open List
open Printf

open Test_functions
open Test_operators
open Test_flow
open Test_optimiser

let tests = concat [
  Test_operators.tests;
  Test_functions.tests;
  Test_flow.tests;
  Test_optimiser.tests;
]

let passed (s, f, e) = (s + 1, f, e)

let pass_if_equal (s, f, e) got expected =
  let p1 = Compiler.prettify got in
  let p2 = Compiler.prettify expected in
  if 0 == compare p1 p2 then (s + 1, f, e)
  else (s, f + 1, e)

let failed (s, f, e) msg =
  (print_endline ("Failed: " ^ msg); (s, f + 1, e))

let error (s, f, e) err =
  ((print_endline ("Error: " ^ err)); (s, f, e + 1))

let test tally (input, expected) =
  let parsed = (Compiler.parse input) in
  match (parsed, expected) with
    | (Parse p, OK) -> passed tally
    | (Parse p, OPT_EQ b) -> (
        match Compiler.parse_and_optimise b with
          | Parse p2 -> pass_if_equal tally (Optimiser.fold_program p) p2
        )
    | (SyntaxError _, SE) -> passed tally
    | (ParseError _, PE) -> passed tally

    | (SyntaxError msg, OK) -> failed tally ("Testing: " ^ input ^ "\nSyntax Error: " ^ msg)
    | (ParseError msg, OK) -> failed tally ("Testing: " ^ input ^ "\nParse Error: " ^ msg)
    | (_, _) -> failed tally "got a syntax error when I expected a Parse error (or vice versa)"

let testall ts = List.fold_left test (0, 0, 0) ts

let _ =
  match (testall tests) with
    (succs, fails, errs) ->
      (Printf.eprintf "%d Successes, %d Failures, %d Errors\n" succs fails errs;
      if fails + errs > 0 then exit 1 else exit 0)
