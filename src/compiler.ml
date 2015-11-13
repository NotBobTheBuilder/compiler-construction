open Lexing
open Printf
open List
open String
open Optimiser
open Asm
open Js

type parse_result =
  | AST of program
  | SyntaxError of string
  | ParseError of string

let string_of_position lexbuf =
  let pos = lexbuf.lex_curr_p in
  let line = string_of_int pos.pos_lnum in
  let col = string_of_int (pos.pos_cnum - pos.pos_bol) in
  "Line "^line^", Column "^col

let parse' lexbuf = try
  let statements = (Parser.top Lexer.read lexbuf) in AST (program_scope statements, statements)
  with
  | Lexer.SyntaxError msg ->  SyntaxError (string_of_position lexbuf)
  | Parser.Error ->           ParseError (string_of_position lexbuf)

let parse s = parse' (Lexing.from_string s)

let parse_and_optimise s =  let result = parse s in
                            match result with
                              | AST (_, ss) -> AST (Optimiser.fold_program ss)
                              | _ -> result

let to_ast (scope, p) = String.concat " " (List.map Js.string_of_statement p)
let to_x86 = Asm.compile
