type result =
  | OK
  | SE
  | PE

let parse_ok a = (a, OK)
let parse_se a = (a, SE)
let parse_pe a = (a, PE)
