open Utils
open Compiler
open Js
open List
open Printf

open Test_functions
open Test_operators
open Test_flow
open Test_optimiser
open Test_runtime

let parser_tests = concat [
  Test_operators.tests;
  Test_functions.tests;
  Test_flow.tests;
  Test_optimiser.tests;
]

let runtime_tests = concat [
  Test_runtime.tests;
]

let passed (s, f, e) = (s + 1, f, e)

let pass_if_equal (s, f, e) got expected =
  let p1 = Compiler.to_ast got in
  let p2 = Compiler.to_ast expected in
  if 0 == compare p1 p2 then (s + 1, f, e)
  else (s, f + 1, e)

let failed (s, f, e) msg =
  (print_endline ("Failed: " ^ msg); (s, f + 1, e))

let error (s, f, e) err =
  ((print_endline ("Error: " ^ err)); (s, f, e + 1))

let parser_test tally (input, expected) =
  let parsed = (Compiler.parse input) in
  match (parsed, expected) with
    | (Parse (s, p), OK) -> passed tally
    | (Parse (s, p), OPT_EQ b) -> (
        match Compiler.parse_and_optimise b with
          | Parse (s2, p2) -> pass_if_equal tally (s, (Optimiser.fold_program p)) (s2, p2)
        )
    | (SyntaxError _, SE) -> passed tally
    | (ParseError _, PE) -> passed tally

    | (SyntaxError msg, OK) -> failed tally ("Testing: " ^ input ^ "\nSyntax Error: " ^ msg)
    | (ParseError msg, OK) -> failed tally ("Testing: " ^ input ^ "\nParse Error: " ^ msg)
    | (_, _) -> failed tally "\tgot a syntax error when I expected a Parse error (or vice versa)"

let all_parser_tests = List.fold_left parser_test (0, 0, 0) parser_tests

let runtime_test (succ, err) (program, expected) =
  let res = Sys.command ("./main.native -q -c '"^program^"'") in
  let sres = string_of_int res in
  let sexp = string_of_int expected in
  if res == expected then (succ+1, err) else (
    print_endline ("Runtime Test Failed: "^ program ^"\n\tgot "^sres^", expected "^sexp);
    (succ, err+1)
    )

let all_runtime_tests = List.fold_left runtime_test (0, 0) runtime_tests

let test_total (psucc, pfail, perr) (rsucc, rfail) = (psucc+rsucc, pfail+rfail, perr)

let _ =
  match (test_total all_parser_tests all_runtime_tests) with
    (succs, fails, errs) ->
      (Printf.eprintf "%d Successes, %d Failures, %d Errors\n" succs fails errs;
      if fails + errs > 0 then exit 1 else exit 0)
