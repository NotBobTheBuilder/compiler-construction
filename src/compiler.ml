open Lexing
open Printf
open List
open String

type parse_result =
  | Parse of Js.statement list
  | SyntaxError of string
  | ParseError of string

let string_of_position lexbuf =
  let pos = lexbuf.lex_curr_p in
  let line = string_of_int pos.pos_lnum in
  let col = string_of_int (pos.pos_cnum - pos.pos_bol) in
  "Line "^line^", Column "^col

let parse' lexbuf =
  try Parse (Parser.top Lexer.read lexbuf) with
  | Lexer.SyntaxError msg ->  SyntaxError (string_of_position lexbuf)
  | Parser.Error ->           ParseError (string_of_position lexbuf)

let parse s = parse' (Lexing.from_string s)

let optimise ast = ast

let prettify p =
  String.concat " " (List.map Js.string_of_statement p)

let prettyPrint p =
  List.iter print_endline (List.map Js.string_of_statement p)
