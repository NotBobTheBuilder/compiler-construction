open String
open List
open Scope

type params = string list
and fname = string option
and scope = Scope.t
and block = statement list
and program = (scope * block)
and statement =
  | Return of expr
  | Declare of (string * expr)
  | Assign of (string * expr)
  | While of (expr * block)
  | If of (expr * block)
  | IfElse of (expr * block * block)
  | Expr of expr
and expr =
  | Add of (expr * expr)
  | Sub of (expr * expr)
  | Mul of (expr * expr)
  | Div of (expr * expr)
  | Mod of (expr * expr)
  | Lt of (expr * expr)
  | LtEq of (expr * expr)
  | Gt of (expr * expr)
  | GtEq of (expr * expr)
  | Eq of (expr * expr)
  | True
  | False
  | Undefined
  | Ident of string
  | Number of int
  | Function of (fname * params * scope * block)
  | Call of (string * expr list)

let rec string_of_block b = "{ " ^ (String.concat " " (List.map string_of_statement b)) ^ " }"

and string_of_function name params body =
  let ps = String.concat ", " params in
  let b = string_of_block body in
  match name with
  | None ->   "(Function <anonymous> (" ^ ps ^ ") " ^ b ^ ")"
  | Some n -> "(Function '" ^ n ^ "' (" ^ ps ^ ") " ^ b ^ ")"

and string_of_expr e = match e with
  | Add (lhs, rhs) -> "(Add " ^ (string_of_expr lhs) ^ ", " ^ (string_of_expr rhs) ^ ")"
  | Sub (lhs, rhs) -> "(Sub " ^ (string_of_expr lhs) ^ ", " ^ (string_of_expr rhs) ^ ")"
  | Mul (lhs, rhs) -> "(Mul " ^ (string_of_expr lhs) ^ ", " ^ (string_of_expr rhs) ^ ")"
  | Div (lhs, rhs) -> "(Div " ^ (string_of_expr lhs) ^ ", " ^ (string_of_expr rhs) ^ ")"
  | Mod (lhs, rhs) -> "(Mod " ^ (string_of_expr lhs) ^ ", " ^ (string_of_expr rhs) ^ ")"
  | Lt (lhs, rhs) -> "(< " ^ (string_of_expr lhs) ^ ", " ^ (string_of_expr rhs) ^ ")"
  | LtEq (lhs, rhs) -> "(<= " ^ (string_of_expr lhs) ^ ", " ^ (string_of_expr rhs) ^ ")"
  | Gt (lhs, rhs) -> "(> " ^ (string_of_expr lhs) ^ ", " ^ (string_of_expr rhs) ^ ")"
  | GtEq (lhs, rhs) -> "(>= " ^ (string_of_expr lhs) ^ ", " ^ (string_of_expr rhs) ^ ")"
  | Eq (lhs, rhs) -> "(== " ^ (string_of_expr lhs) ^ ", " ^ (string_of_expr rhs) ^ ")"
  | Ident i -> "(Ident " ^ i ^ ")"
  | Number n -> "(Number " ^ (string_of_int n) ^ ")"
  | Undefined -> "(Undefined)"
  | True -> "(True)"
  | False -> "(False)"
  | Function (name, params, scope, body) -> string_of_function name params body
  | Call (name, params) -> "(Call '" ^ name ^ "' with [" ^ (String.concat "," (map string_of_expr params)) ^ "])"

and string_of_statement s = match s with
  | Return e ->         let exp = string_of_expr e in
                          "(Return " ^ exp ^ ")"
  | Declare (id, e) ->  let exp = string_of_expr e in
                          "(Declare '" ^ id ^"' " ^ exp ^ ");"
  | Assign (id, e) ->   let exp = string_of_expr e in
                          "(Assign '" ^ id ^"' " ^ exp ^ ");"
  | While (c, b) ->     let exp = string_of_expr c in
                        let block = string_of_block b in
                          "(While (" ^ exp ^") " ^ block ^ ")"
  | If (c, t) ->        let exp = string_of_expr c in
                        let trueBlock = string_of_block t in
                          "(If (" ^ exp ^") " ^ trueBlock ^ ")"
  | IfElse (c, t, f) -> let exp = string_of_expr c in
                        let trueBlock = string_of_block t in
                        let falseBlock = string_of_block f in
                          "(IfElse (" ^ exp ^") " ^ trueBlock ^ " " ^ falseBlock ^ ")"
  | Expr e ->           let exp = string_of_expr e in
                          "(Expr " ^ exp ^ ");"

let rec p' (s, ss) this = match this with
  | Expr (Function (n, ps, s, b)) -> let (scope, b') = psb b in
                              let s' = Scope.add_all ps scope in
                              (s', [Expr(Function (n, ps, s', b'))]@ss)
  | Declare (id, a) -> (Scope.add id None s, [Declare (id,a)]@ss)
  | a -> (s, [a]@ss)
and psb statements =
  let (a,b) = List.fold_left p' (Scope.new_scope Scope.empty, []) statements in
  (a, rev b)
