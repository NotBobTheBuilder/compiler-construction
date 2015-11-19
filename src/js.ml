open String
open List
module StringMap = Map.Make(String)

type params = string list
and fname = string option
and scope = int option StringMap.t
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


let scope_builder initial_scope statements = List.fold_left (fun scope v -> match v with
  | Declare (id, expr) -> StringMap.add id None scope
  | _ -> scope
  ) initial_scope statements

let scope_of_parameters = List.fold_left (fun scope e -> StringMap.add e None scope) StringMap.empty

let program_scope = scope_builder StringMap.empty
let function_scope ps = scope_builder (scope_of_parameters ps)
