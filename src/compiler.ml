open Lexing
open Printf
open List
open String

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

let prettify p =
  String.concat " " (List.map Js.string_of_statement p)

let prettyPrint p =
    List.map Js.string_of_statement p
    |> List.map print_endline
