{
open Parser
exception SyntaxError of string
}

let int = ['0'-'9'] ['0'-'9']*
let ident = ['a'-'z' 'A'-'Z' '_'] ['a'-'z' 'A'-'Z' '0'-'9' '_']*
let white = [' ' '\t']+
let newline = '\r' | '\n' | "\r\n"

rule read =
    parse
    | white       { read lexbuf }
    | newline     { read lexbuf }
    | "var"       { VAR }
    | "function"  { FUNCTION }
    | "true"      { TRUE }
    | "false"     { FALSE }
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
    | ';'         { SEMICOLON }
    | '='         { EQ }
    | int         { NUMBER (int_of_string (Lexing.lexeme lexbuf)) }
    | ident       { IDENT (Lexing.lexeme lexbuf) }
    | _  { raise (SyntaxError ("Unexpected char: " ^
                               Lexing.lexeme lexbuf)) }
    | eof  { EOF }
