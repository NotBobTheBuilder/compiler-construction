open String
open List
module StringSet = Set.Make(String)

type params = string list
and fname = string option
and scope = string list
and block = statement list
and program = (scope * block)
and statement =
  | Return of expr
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
  | Ident of string
  | Number of int
  | Function of (fname * params * scope * block)
  | Call of (string * expr list)

let rec string_of_block b = "{ " ^ (String.concat " " (map string_of_statement b)) ^ " }"

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
  | True -> "(True)"
  | False -> "(False)"
  | Function (name, params, scope, body) -> string_of_function name params body
  | Call (name, params) -> "(Call '" ^ name ^ "' with [" ^ (String.concat "," (map string_of_expr params)) ^ "])"

and string_of_statement s = match s with
  | Return e ->         let exp = string_of_expr e in
                          "(Return " ^ exp ^ ")"
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


let scope_builder init b = StringSet.elements (List.fold_left (fun vars v -> match v with
  | Assign (id, expr) -> StringSet.add id vars
  | _ -> vars
  ) init b)

let program_scope = scope_builder StringSet.empty
let function_scope ps = scope_builder (StringSet.of_list ps)
