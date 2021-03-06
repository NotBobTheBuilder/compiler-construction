open List
open Js
open String
module StringMap = Map.Make(String)

let rec fold_expr scope = function
  | Add (lhs, rhs) ->   let fl = fold_expr scope lhs in
                        let fr = fold_expr scope rhs in
                        (match (fl, fr) with
                          | (Number n1, Number n2) -> Number (n1+n2)
                          | _ -> Add (fl, fr))
  | Sub (lhs, rhs) ->   let fl = fold_expr scope lhs in
                        let fr = fold_expr scope rhs in
                        (match (fl, fr) with
                          | (Number n1, Number n2) -> Number (n1-n2)
                          | _ -> Sub (fl, fr))
  | Mul (lhs, rhs) ->   let fl = fold_expr scope lhs in
                        let fr = fold_expr scope rhs in
                        (match (fl, fr) with
                          | (Number n1, Number n2) -> Number (n1*n2)
                          | _ -> Mul (fl, fr))
  | Lt (lhs, rhs) ->    let fl = fold_expr scope lhs in
                        let fr = fold_expr scope rhs in
                        (match (fl, fr) with
                          | (Number n1, Number n2) -> if n1 < n2 then True else False
                          | _ -> Lt (fl, fr))
  | LtEq (lhs, rhs) ->  let fl = fold_expr scope lhs in
                        let fr = fold_expr scope rhs in
                        (match (fl, fr) with
                          | (Number n1, Number n2) -> if n1 <= n2 then True else False
                          | _ -> Lt (fl, fr))
  | Gt (lhs, rhs) ->    let fl = fold_expr scope lhs in
                        let fr = fold_expr scope rhs in
                        (match (fl, fr) with
                          | (Number n1, Number n2) -> if n1 > n2 then True else False
                          | _ -> Lt (fl, fr))
  | GtEq (lhs, rhs) ->  let fl = fold_expr scope lhs in
                        let fr = fold_expr scope rhs in
                        (match (fl, fr) with
                          | (Number n1, Number n2) -> if n1 >= n2 then True else False
                          | _ -> Lt (fl, fr))
  | Eq (lhs, rhs) ->    let fl = fold_expr scope lhs in
                        let fr = fold_expr scope rhs in
                        (match (fl, fr) with
                          | (Number n1, Number n2) -> if n1 == n2 then True else False
                          | _ -> Lt (fl, fr))
  | Function (n, ps, fs, b) -> let (s, b) = fold_block (Scope.concat fs scope) b in Function (n, ps, s, b)
  | Call (name, es) ->      let fs = List.map (fold_expr scope) es in Call (name, fs)
  | Ident a -> (if Scope.mem a scope then (match Scope.find a scope with
      | Some n -> Number n
      | None -> Ident a)
    else Ident a)
  | a -> a

and is_truthy = function
  | True -> true
  | Number n -> n > 0
  | _ -> false

and is_falsy = function
  | False -> true
  | Number 0 -> true
  | _ -> false

and fold_while (scope:Scope.t) c ss =       let fc = fold_expr scope c in
                                  if is_falsy fc then []
                                  else let (_, b) = fold_block scope ss in [While (c, b)]

and fold_if (scope:Scope.t) c ss =          let fc = fold_expr scope c in
                                  if is_falsy fc then []
                                  else let (_, fs) = fold_block scope ss in
                                  if is_truthy fc then fs else [If (fc, fs)]

and fold_if_else (scope:Scope.t) c ts fs =  let fc = fold_expr scope c in
                                  let (_, ffs) = fold_block scope fs in
                                  let (_, fts) = fold_block scope ts in
                                  if is_falsy fc then ffs
                                  else if is_truthy fc then fts
                                  else [IfElse (fc, fts, ffs)]

and fold_statement (scope:Scope.t) = function
  | Return e -> [Return (fold_expr scope e)]
  | Assign (i, e) -> [Assign (i, fold_expr scope e)]
  | Declare (i, e) -> [Declare (i, fold_expr scope e)]
  | While (c, ss) -> fold_while scope c ss
  | If (c, ts) -> fold_if scope c ts
  | IfElse (c, ts, fs) -> fold_if_else scope c ts fs
  | Expr e -> [Expr (fold_expr scope e)]

and fold_block' (scope:Scope.t) statements = match statements with
  | [] -> []
  (* drop dead code after return *)
  | (Return e)::tl -> [Return (fold_expr scope e)]
  | hd::tl -> (fold_statement scope hd) @ (fold_block' scope tl)
and fold_block (scope:Scope.t) statements = let (inner, stats) = hoist_consts statements in (inner::scope, fold_block' (inner::scope) stats)

and is_const v = match fold_statement Scope.empty v with
  | [Declare (i, Number _)] -> true
  | _ -> false

and extract_consts cs dec = match fold_statement Scope.empty dec with
  | [Declare (i, Number n)] -> StringMap.add i (Some n) cs
  | [Declare (i, _)] -> StringMap.add i None cs
  | _ -> cs

and hoist_consts ss =
  let (consts, rs) = List.partition is_const ss in
  let const_scope = List.fold_left extract_consts StringMap.empty consts in
  (const_scope, rs)

let fold_program = fold_block
