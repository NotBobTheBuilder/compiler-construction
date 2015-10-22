open Arg
open List
open String

let optimisation = ref false
let param_specs = [
  ("-o", Arg.Set optimisation, "Enable Optimisation")
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
                      let result = Compiler.parse input in
                      match result with
                        | Compiler.Parse ast ->
                          if !optimisation then Compiler.Parse (Compiler.optimise ast)
                          else result
                        | _ -> result

let _ =
  match compiler_chain with
    | Compiler.Parse ss -> Compiler.prettyPrint ss
    | Compiler.SyntaxError msg -> print_endline ("Syntax Error: " ^ msg)
    | Compiler.ParseError msg -> print_endline ("Parse Error: " ^ msg)
