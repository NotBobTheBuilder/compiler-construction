open List
module StringMap = Map.Make(String)

exception Variable_Not_In_Scope of string

type t = int option StringMap.t list

let rec mem var = function
  | [] -> false
  | scope::tl -> (StringMap.mem var scope) || mem var tl

let new_scope scope = StringMap.empty::scope

let string_of_intopt = function
  | None -> "None"
  | Some i -> "Some(" ^ (string_of_int i) ^ ")"
let string_of_bindings bs = String.concat ", " (List.map (fun (a,b) -> a^": " ^ (string_of_intopt b)) bs)
let string_of_scope s = "{ " ^ (string_of_bindings (StringMap.bindings s)) ^ " }"

let rec index e = function
  | [] -> raise (Variable_Not_In_Scope ("index of " ^ e))
  | hd::tl -> if 0 == compare hd e then 1 else 1 + index e tl

let rec offset' var = function
  | [] -> raise (Variable_Not_In_Scope ("offset of " ^ var))
  | hd::tl -> if StringMap.mem var hd
              then index var (List.map fst (StringMap.bindings hd))
              else (StringMap.cardinal hd) + offset' var tl

let offset a b = try string_of_int (-8 * (offset' a b)) with
  | Variable_Not_In_Scope v -> raise (Variable_Not_In_Scope (v ^ (String.concat "," (List.map string_of_scope b))))

let rec find var = function
  | [] -> None
  | hd::tl -> if StringMap.mem var hd
              then StringMap.find var hd
              else find var tl

let rec add var value = function
  | [] -> add var value (new_scope [])
  | hd::tl -> (StringMap.add var value hd)::tl

let concat a b = List.concat [a;b]

let empty = []

let from_list ids = List.fold_left (fun s i -> StringMap.add i None s) (StringMap.empty) ids

let merge' id a b = match a with
  | Some x -> Some x
  | None -> b

let merge a b = StringMap.merge merge' a b

let rec add_all ids s = match s with
  | [] -> add_all ids (new_scope [])
  | hd::tl -> (merge (from_list ids) hd)::tl

let size s = List.fold_left (fun t a -> t + StringMap.cardinal a) 0 s
