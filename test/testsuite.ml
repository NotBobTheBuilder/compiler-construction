open Utils
open Compiler
open Js
open List
open Printf

open Test_functions
open Test_operators

let tests = concat [
  Test_operators.tests;
  Test_functions.tests;
]

let passed (s, f, e) = (s + 1, f, e)

let failed (s, f, e) msg =
  (print_endline ("Failed: " ^ msg); (s, f + 1, e))

let error (s, f, e) err =
  ((print_endline ("Error: " ^ err)); (s, f, e + 1))

let test tally (input, expected) =
  let parsed = (Compiler.eval input) in
  match (parsed, expected)  with
  | (Parse p, OK) -> passed tally
  | (SyntaxError _, SE) -> passed tally
  | (ParseError _, PE) -> passed tally

  | (SyntaxError msg, OK) -> failed tally ("Testing: " ^ input ^ "\nSyntax Error: " ^ msg)
  | (ParseError msg, OK) -> failed tally ("Testing: " ^ input ^ "\nParse Error: " ^ msg)
  | (_, _) -> failed tally "got a syntax error when I expected a Parse error (or vice versa)"

let testall ts = List.fold_left test (0, 0, 0) ts

let _ =
  match (testall tests) with
    (succs, fails, errs) ->
      Printf.eprintf "%d Successes, %d Failures, %d Errors\n" succs fails errs
