{
(* This block from RWOC *)
(* https://github.com/realworldocaml/examples/blob/32ea926861a0b728813a29b0e4cf20dd15eb486e/code/parsing/lexer.mll *)
open Lexing
open Parser
exception SyntaxError of string

let next_line lexbuf =
  let pos = lexbuf.lex_curr_p in
  lexbuf.lex_curr_p <-
    { pos with pos_bol = lexbuf.lex_curr_pos;
               pos_lnum = pos.pos_lnum + 1
    }
}

let int = ['0'-'9'] ['0'-'9']*
let ident = ['a'-'z' 'A'-'Z' '_'] ['a'-'z' 'A'-'Z' '0'-'9' '_']*
let white = [' ' '\t']+
let newline = '\r' | '\n' | "\r\n"

rule read =
    parse
    | white       { read lexbuf }
    | newline     { next_line lexbuf; read lexbuf }
    | "var"       { VAR }
    | "for"       { FOR }
    | "function"  { FUNCTION }
    | "return"    { RETURN }
    | "true"      { TRUE }
    | "false"     { FALSE }
    | "undefined" { UNDEFINED }
    | "if"        { IF }
    | "else"      { ELSE }
    | "while"     { WHILE }
    | '('         { BRACKET_OPEN }
    | ')'         { BRACKET_CLOSE }
    | '{'         { BRACE_OPEN }
    | '}'         { BRACE_CLOSE }
    | ','         { COMMA }
    | '+'         { ADD }
    | '-'         { SUB }
    | '*'         { MUL }
    | '/'         { DIV }
    | '%'         { MOD }
    | '<'         { LT }
    | "<="        { LTEQ }
    | '>'         { GT }
    | ">="        { GTEQ }
    | "=="        { EQEQ }
    | ';'         { SEMICOLON }
    | '='         { EQ }
    | int         { NUMBER (int_of_string (Lexing.lexeme lexbuf)) }
    | ident       { IDENT (Lexing.lexeme lexbuf) }
    | _  { raise (SyntaxError ("Unexpected char: " ^
                               Lexing.lexeme lexbuf)) }
    | eof  { EOF }
