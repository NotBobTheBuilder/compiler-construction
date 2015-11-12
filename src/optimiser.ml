open List
open Js
open String
module StringMap = Map.Make(String)

let is_var = function
  | Declare _ -> true
  | _ -> false

let rec fold_expr = function
  | Add (lhs, rhs) ->   let fl = fold_expr lhs in
                        let fr = fold_expr rhs in
                        (match (fl, fr) with
                          | (Number n1, Number n2) -> Number (n1+n2)
                          | _ -> Add (fl, fr))
  | Sub (lhs, rhs) ->   let fl = fold_expr lhs in
                        let fr = fold_expr rhs in
                        (match (fl, fr) with
                          | (Number n1, Number n2) -> Number (n1-n2)
                          | _ -> Sub (fl, fr))
  | Mul (lhs, rhs) ->   let fl = fold_expr lhs in
                        let fr = fold_expr rhs in
                        (match (fl, fr) with
                          | (Number n1, Number n2) -> Number (n1*n2)
                          | _ -> Mul (fl, fr))
  | Lt (lhs, rhs) ->    let fl = fold_expr lhs in
                        let fr = fold_expr rhs in
                        (match (fl, fr) with
                          | (Number n1, Number n2) -> if n1 < n2 then True else False
                          | _ -> Lt (fl, fr))
  | LtEq (lhs, rhs) ->  let fl = fold_expr lhs in
                        let fr = fold_expr rhs in
                        (match (fl, fr) with
                          | (Number n1, Number n2) -> if n1 <= n2 then True else False
                          | _ -> Lt (fl, fr))
  | Gt (lhs, rhs) ->    let fl = fold_expr lhs in
                        let fr = fold_expr rhs in
                        (match (fl, fr) with
                          | (Number n1, Number n2) -> if n1 > n2 then True else False
                          | _ -> Lt (fl, fr))
  | GtEq (lhs, rhs) ->  let fl = fold_expr lhs in
                        let fr = fold_expr rhs in
                        (match (fl, fr) with
                          | (Number n1, Number n2) -> if n1 >= n2 then True else False
                          | _ -> Lt (fl, fr))
  | Eq (lhs, rhs) ->    let fl = fold_expr lhs in
                        let fr = fold_expr rhs in
                        (match (fl, fr) with
                          | (Number n1, Number n2) -> if n1 == n2 then True else False
                          | _ -> Lt (fl, fr))
  | Function (n, ps, scope, b) ->  let (_, fb) = fold_block scope b in Function (n, ps, scope, fb)
  | Call (name, es) ->      let fs = List.map fold_expr es in Call (name, fs)
  | a -> a

and is_truthy = function
  | True -> true
  | Number n -> n > 0
  | _ -> false

and is_falsy = function
  | False -> true
  | Number 0 -> true
  | _ -> false

and fold_while scope c ss = let fc = fold_expr c in
                      if is_falsy fc then []
                      else let (_, fs) = fold_block scope ss in [While (c, fs)]

and fold_if scope c ss =    let fc = fold_expr c in
                      if is_falsy fc then []
                      else let (_, fs) = fold_block scope ss in
                      if is_truthy fc then fs else [If (fc, fs)]

and fold_if_else scope c ts fs =  let fc = fold_expr c in
                            let (_, ffs) = fold_block scope fs in
                            let (_, fts) = fold_block scope ts in
                            if is_falsy fc then ffs
                            else if is_truthy fc then fts
                            else [IfElse (fc, fts, ffs)]

and fold_statement scope = function
  | Return e -> [Return (fold_expr e)]
  | Assign (i, e) -> [Assign (i, fold_expr e)]
  | Declare (i, e) -> [Declare (i, fold_expr e)]
  | While (c, ss) -> fold_while scope c ss
  | If (c, ts) -> fold_if scope c ts
  | IfElse (c, ts, fs) -> fold_if_else scope c ts fs
  | Expr e -> [Expr (fold_expr e)]

and fold_block' scope statements = match statements with
  | [] -> (scope, [])
  (* drop dead code after return *)
  | (Return e)::tl -> (scope, [Return (fold_expr e)])
  | hd::tl -> let (_, ss) = (fold_block' scope tl) in (scope, List.append (fold_statement scope hd) ss)
and fold_block scope statements = let (s, ss) = (hoist_vars scope statements) in fold_block' s ss
and hoist_vars scope ss =
  let (vars, fs) = List.partition is_var ss in
  let names = List.fold_left (fun acc var -> match var with
     | Declare (i, exp) -> i::acc
     | _ -> acc
  ) [] vars in
  let scope = List.fold_left (fun acc var -> StringMap.add var None acc) StringMap.empty names in
  (scope, List.concat [vars; fs])

let fold_program = fold_block
