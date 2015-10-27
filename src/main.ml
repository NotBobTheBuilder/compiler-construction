open Arg
open List
open String
open Printf

let write_to_file fname s =
  let oc = open_out fname in
  Printf.fprintf oc "%s" s;
  close_out oc

let parse_function = ref Compiler.parse
let set_optimisation _ = parse_function := Compiler.parse_and_optimise

let output_function = ref (write_to_file "out.asm")
let set_output_file = function
  | "-" -> output_function := print_endline
  | fname -> output_function := (write_to_file fname)

let compile_function = ref Compiler.to_x86
let set_ast_only _ = compile_function := Compiler.to_ast

let param_specs = [
  ("-O", Arg.Unit set_optimisation, "Enable Optimisation");
  ("-o", Arg.String set_output_file, "Specify output file");
  ("--ast", Arg.Unit set_ast_only , "Just build & print the AST");
]
let drop x = ()
let usage_msg = "main.native [-o]"
let _ = Arg.parse param_specs drop usage_msg

let rec read_to_empty buf =
  let s = read_line () in
    if s = "" then buf
    else (Buffer.add_string buf s;
          Buffer.add_string buf "\n";
          read_to_empty buf)

let load_from_stdio = Buffer.contents (read_to_empty (Buffer.create 1))

let _ =
  match !parse_function load_from_stdio with
    | Compiler.Parse ss -> !output_function (!compile_function ss)
    | Compiler.SyntaxError msg -> prerr_endline ("Syntax Error: " ^ msg)
    | Compiler.ParseError msg -> prerr_endline ("Parse Error: " ^ msg)
