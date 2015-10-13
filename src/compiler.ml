open Lexing
open Printf
open List

let print_position lexbuf =
  let pos = lexbuf.lex_curr_p in
  Printf.eprintf "Pos %d:%d:%d\n" pos.pos_lnum pos.pos_bol pos.pos_cnum

let parse_with_error lexbuf =
  try Parser.top Lexer.read lexbuf with
  | Lexer.SyntaxError msg ->  prerr_string (msg ^ ": ");
                        print_position lexbuf;
                        exit (-1)
  | Parser.Error ->    prerr_string "Parse error: ";
                        print_position lexbuf;
                        exit (-1)

let eval s =
    Lexing.from_string s
    |> parse_with_error
    |> map Js.string_of_statement
    |> map print_endline
