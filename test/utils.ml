open Sys

type result =
  | OK
  | SE
  | PE
  | OPT_EQ of string
  | RES_EQ of int

let parse_ok a = (a, OK)
let parse_se a = (a, SE)
let parse_pe a = (a, PE)

let parse_eq a b = (a, OPT_EQ b)

let run_js a b = (a, b, true)
let run_js_no_opt a b = (a, b, false)
