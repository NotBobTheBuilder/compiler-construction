type result =
  | OK
  | SE
  | PE
  | OPT_EQ of string

let parse_ok a = (a, OK)
let parse_se a = (a, SE)
let parse_pe a = (a, PE)

let parse_eq a b = (a, OPT_EQ b)
