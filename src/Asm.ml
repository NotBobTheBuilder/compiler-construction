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
\tpushq    $0
"
(* These don't seem to work - segfaults :( *)
let asm_alloc s = let size = string_of_int (8*(1+(List.length s))) in "
\tsubq $" ^ size ^", %rsp
"

let asm_free s = let size = string_of_int (8*(1+(List.length s))) in "
\tpopq %rsi
\taddq $" ^ size ^", %rsp
"

let asm_exit_printing_rsi = "
\tleaq format(%rip), %rdi
\tcall _printf
\tmovq $0, %rdi
\tcall _exit
"

let asm_bin_opp o = "
\tpopq %rdi
\tpopq %rsi
\t" ^ o ^ " %rdi, %rsi
\tpushq %rsi
"

let asm_add = asm_bin_opp "addq"
let asm_sub = asm_bin_opp "subq"
let asm_mul = asm_bin_opp "imulq"

let asm_push n = "
\tpushq $" ^ (string_of_int n) ^ "
"

let asm_set_var o = "
\tpopq %rsi
\tmovq %rsi, " ^ o ^ "(%rbp)
"

let asm_get_var o = "
\tmovq " ^ o ^ "(%rbp), %rsi
\tpushq %rsi
"

let rec index e = function
  | [] -> None
  | hd::tl -> if 0 == compare hd e  then Some 1
                          else (match index e tl with
                                | None -> None
                                | Some x -> Some (x+1))

let rec offset scope id = match index id scope with
  | None -> raise Variable_Not_In_Scope
  | Some o -> string_of_int (-8*o)

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
  ^ asm_alloc scope
  ^ (String.concat " " (List.map (asm_of_statement scope) statements))
  ^ asm_free scope
  ^ asm_exit_printing_rsi
