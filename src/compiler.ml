open Lexing
open Printf
open List
open String
open Optimiser
open Asm
open Js

type parse_result =
  | Parse of program
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

let parse_and_optimise s =  let result = parse s in
                            match result with
                              | Parse (scope, ast) -> Parse (Optimiser.fold_program scope ast)
                              | _ -> result

let to_ast (scope, p) = String.concat " " (List.map Js.string_of_statement p)
let to_x86 = Asm.compile
