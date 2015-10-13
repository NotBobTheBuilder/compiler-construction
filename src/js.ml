open String
open List

(*
  Expr is parameterised out so a circular reference can exist between
  Expr and Statement. This is because functions are expressions
  containing statements, which can in turn contain expressions.
*)
type 'e statement =
  | Assign of (string * 'e)
  | Expr of 'e

type expr =
  | Add of (expr * expr)
  | Sub of (expr * expr)
  | Mul of (expr * expr)
  | Div of (expr * expr)
  | Mod of (expr * expr)
  | True
  | False
  | Ident of string
  | Number of int
  | Function of (string option * string list * expr statement list)

let rec string_of_function name params body = match name with
  | None ->
    let ps = String.concat ", " params in
    "(Function <anonymous> (" ^ ps ^ ") { <body> })"
  | Some n ->
    let ps = String.concat ", " params in
    "(Function '" ^ n ^ "' (" ^ ps ^ ") { <body> })"

let rec string_of_expr e = match e with
  | Add (lhs, rhs) -> "(Add " ^ (string_of_expr lhs) ^ ", " ^ (string_of_expr rhs) ^ ")"
  | Sub (lhs, rhs) -> "(Sub " ^ (string_of_expr lhs) ^ ", " ^ (string_of_expr rhs) ^ ")"
  | Mul (lhs, rhs) -> "(Mul " ^ (string_of_expr lhs) ^ ", " ^ (string_of_expr rhs) ^ ")"
  | Div (lhs, rhs) -> "(Div " ^ (string_of_expr lhs) ^ ", " ^ (string_of_expr rhs) ^ ")"
  | Mod (lhs, rhs) -> "(Mod " ^ (string_of_expr lhs) ^ ", " ^ (string_of_expr rhs) ^ ")"
  | Ident i -> "(Ident " ^ i ^ ")"
  | Number n -> "(Number " ^ (string_of_int n) ^ ")"
  | True -> "(True)"
  | False -> "(False)"
  | Function (name, params, body) -> string_of_function name params body

let string_of_statement s = match s with
  | Expr e -> "(Expr " ^ (string_of_expr e) ^ ");"
  | Assign (id, e) -> "(Assign '" ^ id ^"' " ^ (string_of_expr e) ^ ");"
