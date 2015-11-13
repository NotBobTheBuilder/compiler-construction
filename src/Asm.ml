open Js
open String
module StringMap = Map.Make(String)
open List

exception Variable_Not_In_Scope

let count = ref 0
let label _ = count := !count+1; "label"^(string_of_int !count)

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
  | Declare (i, e) -> (asm_of_expr scope e) ^ (assign scope i)
  | Assign (i, e) -> (asm_of_expr scope e) ^ (assign scope i)
  | Expr e -> asm_of_expr scope e
  | If (c, b) -> (asm_of_expr scope c) ^ (asm_of_if scope b)
and asm_of_if scope block =
  let label_end = label () in (asm_branch_eq0 label_end)
  ^ asm_of_block scope block
  ^ label_end ^ ":\n"
and asm_of_expr scope = function
  | Mul (a, b) -> (asm_of_expr scope a) ^ (asm_of_expr scope b) ^ asm_mul
  | Add (a, b) -> (asm_of_expr scope a) ^ (asm_of_expr scope b) ^ asm_add
  | Sub (a, b) -> (asm_of_expr scope a) ^ (asm_of_expr scope b) ^ asm_sub
  | Number n -> asm_push n
  | Ident i -> get scope i
  | _ -> ""
and asm_of_block scope statements = (String.concat "\n" (List.map (asm_of_statement scope) statements))
and get scope id = asm_get_var (offset scope id)
and assign scope id = asm_set_var (offset scope id)

let compile (scope_map, statements) =
  let scope_vars = List.filter (fun (a, b) -> b == None) (StringMap.bindings scope_map) in
  let scope = List.map fst scope_vars in
  asm_prefix
  ^ asm_alloc scope
  ^ asm_of_block scope statements
  ^ asm_free scope
  ^ asm_exit_printing_rsi
