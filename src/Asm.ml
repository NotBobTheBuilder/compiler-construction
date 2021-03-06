open Js
open String
open Scope
open List

let count = ref 0
let label _ = count := !count+1; "label"^(string_of_int !count)

let rec addresses = function
  | 0 -> []
  | n -> (string_of_int (0+(8*n))):: addresses (n-1)

let get_or_else a = function
  | Some n -> n
  | None -> a

let asm_prefix = "
\t.section    __TEXT,__cstring,cstring_literals
format:
\t.string \"%d\\n\\0\"
\t.section __TEXT,__text,regular,pure_instructions
\t.globl _main

"

let asm_f_call n ps = let prefix = (
                        if ps == 0 then ""
                        else if ps == 1 then "\tpopq %rdi\n"
                        else "\tpopq %rdi\n\tpopq %rsi\n"
                      ) in prefix ^ "
\tcallq "^n^"
\tpushq %rax
"

let asm_f_start n s ps = let size = string_of_int (8*(1+(Scope.size s))) in
                        if ps == 0 then "
" ^ n ^ ":
\tpushq %rbp
\tmovq %rsp, %rbp
\tsubq $" ^ size ^", %rsp
"
                        else if ps == 1 then "
" ^ n ^ ":
\tpushq %rbp
\tmovq %rsp, %rbp
\tsubq $" ^ size ^", %rsp
\tmovq %rdi, -8(%rbp)
"
                        else "
" ^ n ^ ":
\tpushq %rbp
\tmovq %rsp, %rbp
\tsubq $" ^ size ^", %rsp
\tmovq %rdi, -8(%rbp)
\tmovq %rsi, -16(%rbp)
"

let asm_f_end s = let size = string_of_int (8*(1+(Scope.size s))) in "
\tpopq %rax
\taddq $" ^ size ^", %rsp
\tpopq %rbp
\tret

"

let asm_main = "
_main:
\tpushq    $0
"

let asm_alloc s = let size = string_of_int (8*(1+(Scope.size s))) in "
\tsubq $" ^ size ^", %rsp
"

let asm_free s = let size = string_of_int (8*(1+(Scope.size s))) in "
\tpopq %rsi
\taddq $" ^ size ^", %rsp
"

let asm_exit_printing_rsi = "
\tmovq %rsi, %rdi
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

let asm_eq () =
let label1 = label () in
let label2 = label () in
"
\tpopq %rdi
\tpopq %rsi
\tcmp %rsi, %rdi
\tjne "^label1^"
\tpushq $1
\tjmp "^label2^"
"^label1^":
\tpushq $0
"^label2^":
"

let asm_lt () =
let label1 = label () in
let label2 = label () in
"
\tpopq %rdi
\tpopq %rsi
\tcmp %rdi, %rsi
\tjge "^label1^"
\tpushq $1
\tjmp "^label2^"
"^label1^":
\tpushq $0
"^label2^":
"

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

let asm_branch_eq0 l = "
\tpopq %rsi
\tcmp $0, %rsi
\tje "^ l ^"
"

let asm_ja l = "
\tjmp "^ l ^"
"

(* let asm_pop_for_call n = "
\tpopq %rsi
\tmovq %rsi, "^ n ^"(%rbp)
" *)

let rec asm_of_statement scope = function
  | Declare (i, e) -> (asm_of_expr scope e) ^ (assign scope i)
  | Assign (i, e) -> (asm_of_expr scope e) ^ (assign scope i)
  | Expr e -> asm_of_expr scope e
  | If (c, b) -> (asm_of_expr scope c) ^ (asm_of_if scope b)
  | IfElse (c, ts, fs) -> (asm_of_expr scope c) ^ (asm_of_if_else scope ts fs)
  | While (c, ss) -> asm_of_while scope c ss
  | Return e -> (asm_of_expr scope e) ^ asm_f_end scope
and asm_of_if scope block =
  let label_end = label () in
  let (functions, asm_block) = asm_of_block scope block in
  (asm_branch_eq0 label_end)
  ^ asm_block
  ^ label_end ^ ":\n"
and asm_of_if_else scope ts fs =
  let label_else = label () in
  let label_end = label () in
  let (functions_true, asm_block_true) = asm_of_block scope ts in
  let (functions_false, asm_block_false) = asm_of_block scope fs in
  (asm_branch_eq0 label_else)
  ^ asm_block_true
  ^ (asm_ja label_end)
  ^ label_else ^ ":\n"
  ^ asm_block_false
  ^ label_end ^ ":\n"
and asm_of_while scope cond ss =
  let label_start = label () in
  let label_end = label () in
  let (functions, asm_block) = asm_of_block scope ss in
  label_start ^ ":\n"
  ^ asm_of_expr scope cond
  ^ asm_branch_eq0 label_end
  ^ asm_block
  ^ asm_ja label_start
  ^ label_end ^ ":\n"
and asm_of_expr scope = function
  | Mul (a, b) -> (asm_of_expr scope a) ^ (asm_of_expr scope b) ^ asm_mul
  | Add (a, b) -> (asm_of_expr scope a) ^ (asm_of_expr scope b) ^ asm_add
  | Sub (a, b) -> (asm_of_expr scope a) ^ (asm_of_expr scope b) ^ asm_sub
  | Eq (a, b) -> (asm_of_expr scope a) ^ (asm_of_expr scope b) ^ (asm_eq ())
  | Lt (a, b) -> (asm_of_expr scope a) ^ (asm_of_expr scope b) ^ (asm_lt ())
  | Number n -> asm_push n
  | Undefined -> asm_push 0
  | Ident i -> get scope i
  | Function (n, p, s, b) ->
    let name = get_or_else (label ()) n in
    let (_, asm) = asm_of_block s b in
      asm_f_start name s (List.length p)
      ^ asm
  | Call (n, ps) -> (String.concat "\n\n" (List.map (asm_of_expr scope) ps))
    ^ (asm_f_call n (List.length ps))
  | _ -> ""
and asm_of_block scope statements =
  let (functions, block) = hoist_functions statements in
  let asm_of_block' b = String.concat "\n" (List.map (asm_of_statement scope) b) in
    (asm_of_block' functions, asm_of_block' block)
and is_function = function
  | Expr (Function _) -> true
  | _ -> false
and hoist_functions' statement (fs, ss) = match statement with
  | Expr (Function f) -> (Expr (Function f)::fs, ss)
  | Declare (id, Function f) -> (Expr (Function f)::fs, ss)
  | Assign (id, Function f) -> (Expr (Function f)::fs, ss)
  | a -> (fs, a::ss)
and hoist_functions statements = List.fold_right hoist_functions' statements ([], [])
and get scope id = asm_get_var (Scope.offset id scope)
and assign scope id = asm_set_var (Scope.offset id scope)

let compile (scope, statements) =
  let (asm_functions, asm_block) = asm_of_block scope statements in
  asm_prefix
  ^ asm_functions
  ^ asm_main
  ^ asm_alloc scope
  ^ asm_block
  ^ asm_free scope
  ^ asm_exit_printing_rsi
