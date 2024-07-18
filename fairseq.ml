let parse filename = 
  let ic = open_in filename in
  try
    let n = input_line ic in
    let data = input_line ic in
    close_in ic;
    (n, data)
  with e ->
    close_in_noerr ic;
    raise e

let printList list = List.iter (Printf.printf "%F ") list

(* We need one function that scans the low idx and for each element it seeks the high idx*)

let rec seekClosest target (previous, next) =
  match (previous, next) with
  | ([], []) -> (0.0, previous, next)
  | ([], [c]) -> (c, previous, next)
  | ([], (c::n::nList)) -> 
    let cDiff = Float.abs (c -. target) in
    let nDiff = Float.abs (n -. target) in
    if nDiff < cDiff then seekClosest target ([c], (n::nList)) else (c, previous, next)
  | ((p::pList), []) -> (p, previous, next)
  | ((p::pList), [c]) -> 
    let pDiff = Float.abs (p -. target) in
    let cDiff = Float.abs (c -. target) in
    if pDiff < cDiff then seekClosest target (pList, [p; c]) else (c, previous, next)
  | ((p::pList), (c::n::nList)) -> 
    let pDiff = Float.abs (p -. target) in    
    let cDiff = Float.abs (c -. target) in
    let nDiff = Float.abs (n -. target) in
    if nDiff < cDiff && nDiff < pDiff then seekClosest target ((c::p::pList), (n::nList)) else 
    if pDiff < cDiff && pDiff < nDiff then seekClosest target ((pList), (p::c::n::nList)) else (c, previous, next)

let rec findMinDiff maxx (prev, next) = function
  | [] -> maxx
  | (low::rest) ->
    let target = maxx /. 2.0 +. low in
    let (high, p, n) = seekClosest target (prev, next) in
    let diff = abs_float(maxx -. 2.0 *. (high -. low)) in
    min diff (findMinDiff maxx (p, n) rest)

let () =
  if Array.length Sys.argv = 2 then
    let (n, data) = parse Sys.argv.(1) in
    (* print_endline n; *)
    let nums = List.map Float.of_string (String.split_on_char ' ' data) in
    (* printList nums; *)
    let (maxx, rollingSum) = List.fold_left_map (fun x y -> (x +. y, x)) 0.0 nums in
    (* print_newline ();
    printList rollingSum;
    print_float maxx;
    print_newline (); *)
    print_int (int_of_float (findMinDiff maxx ([], rollingSum) rollingSum));
    print_newline ()
  else 
    print_endline "Wrong Input!\n"        