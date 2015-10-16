open String
open List

type statement =
  | Return of expr
  | Assign of (string * expr)
  | Expr of expr
and
expr =
  | Add of (expr * expr)
  | Sub of (expr * expr)
  | Mul of (expr * expr)
  | Div of (expr * expr)
  | Mod of (expr * expr)
  | True
  | False
  | Ident of string
  | Number of int
  | Function of (string option * string list * statement list)
  | Call of (string * expr list)

let rec string_of_function name params body =
  let ps = String.concat ", " params in
  let b = String.concat " " (map string_of_statement body) in
  match name with
  | None ->   "(Function <anonymous> (" ^ ps ^ ") { " ^ b ^ " })"
  | Some n -> "(Function '" ^ n ^ "' (" ^ ps ^ ") { " ^ b ^ " })"

and string_of_expr e = match e with
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
  | Call (name, params) -> "(Call '" ^ name ^ "' with [" ^ (String.concat "," (map string_of_expr params)) ^ "])"

and string_of_statement s = match s with
  | Return e -> "(Return " ^ (string_of_expr e) ^ ")"
  | Expr e -> "(Expr " ^ (string_of_expr e) ^ ");"
  | Assign (id, e) -> "(Assign '" ^ id ^"' " ^ (string_of_expr e) ^ ");"
