open Js
open String
open List

let asm_prefix = "
\t.section    __TEXT,__cstring,cstring_literals
format:
\t.string \"%d\\n\\0\"
\t.section __TEXT,__text,regular,pure_instructions
\t.globl _main
_main:
\tpush    $0\n"

let asm_suffix = "
\tlea format(%rip), %rdi
\tpop %rsi
\tcall _printf
\tmov $0, %rdi
\tcall _exit  "

let asm_bin_opp o = "
\tpop %rdi
\tpop %rsi
\t" ^ o ^ " %rdi, %rsi
\tpush %rsi\n"

let asm_add = asm_bin_opp "add"
let asm_sub = asm_bin_opp "sub"
let asm_mul = asm_bin_opp "imul"
let asm_div = asm_bin_opp "div"

let asm_push n = "\tpush $" ^ (string_of_int n) ^ "\n"

let rec asm_of_statement = function
  | Expr e -> asm_of_expr e
and asm_of_expr = function
  | Mul (a, b) -> (asm_of_expr a) ^ (asm_of_expr b) ^ asm_mul
  | Add (a, b) -> (asm_of_expr a) ^ (asm_of_expr b) ^ asm_add
  | Sub (a, b) -> (asm_of_expr a) ^ (asm_of_expr b) ^ asm_sub
  | Div (a, b) -> (asm_of_expr a) ^ (asm_of_expr b) ^ asm_div
  | Number n -> asm_push n
  | _ -> ""

let compile statements = asm_prefix
  ^ (String.concat " " (List.map asm_of_statement statements))
  ^ asm_suffix
