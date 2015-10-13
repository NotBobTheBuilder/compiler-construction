let rec read_to_empty buf =
  let s = read_line () in
    if s = "" then buf
    else (Buffer.add_string buf s;
          Buffer.add_string buf "\n";
          read_to_empty buf)

let _ =
  read_to_empty (Buffer.create 1)
    |> Buffer.contents
    |> Compiler.eval
