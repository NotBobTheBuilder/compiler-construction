open Arg
open List
open String
open Printf
open Sys

let write_to_file fname s =
  let oc = open_out fname in
  Printf.fprintf oc "%s" s;
  close_out oc

let read_from_file fname _ =
  let in_channel = open_in fname in
  let buf = Buffer.create 1 in
  (try
    while true do
      let line = input_line in_channel in
      (Buffer.add_string buf line; Buffer.add_string buf "\n")
    done
  with End_of_file ->
    close_in in_channel
  ); Buffer.contents buf

let rec read_to_empty buf =
  let s = read_line () in
    if s = "" then buf
    else (Buffer.add_string buf s;
          Buffer.add_string buf "\n";
          read_to_empty buf)
let load_from_stdio _ = Buffer.contents (read_to_empty (Buffer.create 1))

let input_function = ref load_from_stdio
let set_input_file = function
  | "-" -> input_function := load_from_stdio
  | fname -> input_function := (read_from_file fname)
let set_input_cli s = input_function := (fun () -> s)

let output_filename = ref "out.asm"

let output_function = ref (write_to_file !output_filename)
let set_output_file = function
  | "-" -> output_function := print_endline
  | fname -> (
    output_filename := fname;
    output_function := (write_to_file fname))

let exec_function = ref (fun _ -> (Sys.command ("cc " ^ !output_filename ^ "; ./a.out")))
let set_no_execution _ = exec_function := (fun _ -> 0)

let parse_function = ref Compiler.parse
let set_optimisation _ = parse_function := Compiler.parse_and_optimise

let compile_function = ref Compiler.to_x86
let set_ast_only _ = compile_function := Compiler.to_ast

let param_specs = [
  ("-O", Arg.Unit set_optimisation, "Enable Optimisation");
  ("-o", Arg.String set_output_file, "Specify output file");
  ("-i", Arg.String set_input_file, "Specify input file");
  ("-c", Arg.String set_input_cli, "Pass code on CLI");
  ("-n", Arg.Unit set_no_execution, "No execution");
  ("--ast", Arg.Unit set_ast_only , "Just build & print the AST");
]

let drop x = ()
let usage_msg = "main.native [-o]"
let _ = Arg.parse param_specs drop usage_msg

let _ =
  match !parse_function (!input_function ()) with
    | Compiler.Parse p -> (!output_function (!compile_function p); exit (!exec_function ()))
    | Compiler.SyntaxError msg -> prerr_endline ("Syntax Error: " ^ msg)
    | Compiler.ParseError msg -> prerr_endline ("Parse Error: " ^ msg)
