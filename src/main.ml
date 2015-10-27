open Arg
open List
open String

let optimisation = ref false
let ast_only = ref false
let param_specs = [
  ("-o", Arg.Set optimisation, "Enable Optimisation");
  ("--ast", Arg.Set ast_only , "Just build & print the AST");
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

let compiler_chain =  let input = load_from_stdio in
                      if !optimisation then Compiler.parse_and_optimise input
                      else Compiler.parse input

let _ =
  match compiler_chain with
    | Compiler.Parse ss -> if !ast_only then Compiler.prettyPrint ss
                                        else Compiler.to_x86 ss
    | Compiler.SyntaxError msg -> print_endline ("Syntax Error: " ^ msg)
    | Compiler.ParseError msg -> print_endline ("Parse Error: " ^ msg)
