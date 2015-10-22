open List
open Js

let rec fold_expr a = match a with
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
  | Function (n, ps, b) ->  let fb = fold_statements b in Function (n, ps, fb)
  | Call (name, es) ->      let fs = map fold_expr es in Call (name, fs)
  | _ -> a

and is_truthy c = match c with
  | True -> true
  | Number n -> n > 0
  | _ -> false

and is_falsy c = match c with
  | False -> true
  | Number 0 -> true
  | _ -> false

and fold_while c ss = let fc = fold_expr c in
                      if is_falsy fc then []
                      else [While (c, fold_statements ss)]

and fold_if c ss =    let fc = fold_expr c in
                      if is_falsy fc then []
                      else let fs = fold_statements ss in
                      if is_truthy fc then fs else [If (fc, fs)]

and fold_if_else c ts fs =  let fc = fold_expr c in
                            let ffs = fold_statements fs in
                            let fts = fold_statements ts in
                            if is_falsy fc then ffs
                            else if is_truthy fc then fts
                            else [IfElse (fc, fts, ffs)]

and fold_statement s = match s with
  | Return e -> [Return (fold_expr e)]
  | Assign (i, e) -> [Assign (i, fold_expr e)]
  | While (c, ss) -> fold_while c ss
  | If (c, ts) -> fold_if c ts
  | IfElse (c, ts, fs) -> fold_if_else c ts fs
  | Expr e -> [Expr (fold_expr e)]

and fold_statements ss = match ss with
  | [] -> []
  (* drop dead code after return *)
  | (Return e)::tl -> [Return (fold_expr e)]
  | hd::tl -> List.append (fold_statement hd) (fold_statements tl)

let fold_program = fold_statements
