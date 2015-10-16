let rec read_to_empty buf =
  let s = read_line () in
    if s = "" then buf
    else (Buffer.add_string buf s;
          Buffer.add_string buf "\n";
          read_to_empty buf)

let eval_from_input =
  Compiler.eval (Buffer.contents (read_to_empty (Buffer.create 1)))

let _ =
  match eval_from_input with
    | Compiler.Parse ss -> Compiler.prettyPrint ss
    | Compiler.SyntaxError msg -> print_endline ("Syntax Error: " ^ msg)
    | Compiler.ParseError msg -> print_endline ("Parse Error: " ^ msg)
