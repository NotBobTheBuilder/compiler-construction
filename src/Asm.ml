open Js
open String
open List

exception Variable_Not_In_Scope

let asm_prefix = "
\t.section    __TEXT,__cstring,cstring_literals
format:
\t.string \"%d\\n\\0\"
\t.section __TEXT,__text,regular,pure_instructions
\t.globl _main
_main:
\tpush    $0
"
(* These don't seem to work - segfaults :( *)
let asm_alloc s = "
\tpush %rbp
\tsub %rsp," ^ (string_of_int s) ^"
"

let asm_free = "
\tmov %rsp, %rbp
\tpop %rbp
"

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
\tpush %rsi
"

let asm_add = asm_bin_opp "addq"
let asm_sub = asm_bin_opp "subq"
let asm_mul = asm_bin_opp "imulq"

let asm_push n = "
\tpush $" ^ (string_of_int n) ^ "
"

let asm_set_var o = "
\tpop %rsi
\tmov %rsi, " ^ o ^ "(%rbp)
"

let asm_get_var o = "
\tmov " ^ o ^ "(%rbp), %rsi
\tpush %rsi
"

let rec index e = function
  | [] -> None
  | hd::tl -> if 0 == compare hd e  then Some 1
                          else (match index e tl with
                                | None -> None
                                | Some x -> Some (x+1))

let rec offset scope id = match index id scope with
  | None -> raise Variable_Not_In_Scope
  | Some o -> string_of_int (-4*o)

let rec asm_of_statement scope = function
  | Assign (i, e) -> (asm_of_expr scope e) ^ (assign scope i)
  | Expr e -> asm_of_expr scope e
and asm_of_expr scope = function
  | Mul (a, b) -> (asm_of_expr scope a) ^ (asm_of_expr scope b) ^ asm_mul
  | Add (a, b) -> (asm_of_expr scope a) ^ (asm_of_expr scope b) ^ asm_add
  | Sub (a, b) -> (asm_of_expr scope a) ^ (asm_of_expr scope b) ^ asm_sub
  | Number n -> asm_push n
  | Ident i -> get scope i
  | _ -> ""
and get scope id = asm_get_var (offset scope id)
and assign scope id = asm_set_var (offset scope id)

let compile (scope, statements) = asm_prefix
  ^ (String.concat " " (List.map (asm_of_statement scope) statements))
  ^ asm_suffix
