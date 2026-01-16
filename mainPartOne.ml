(* Reading from input.txt *)
let file = "input.txt"


(*
  Each input data is associated with a char followed by an integer.
  There can only exist two char values: 'R' and 'L'
 
  Setting turn to R | L makes it easier to read
  instr holds two values: turn and steps for the input type: <char><int>
*)
type turn = R | L

type instr = {
  turn  : turn;
  steps : int;
}



(* Assigns types: turn and instr to the input data *)
(* 
  It makes sure the input can not be anything other than:
    - turn: {R, L}
    - steps: (int) Note: Can use Int64.max_int, but keeping it simple for now
*)
let parse_line (s : string) : instr =
  let dir_char = s.[0] in
  let steps_str = String.sub s 1 (String.length s - 1) in
  (* Start parsing for turn *)
  let turn =
    match dir_char with
    | 'R' -> R
    | 'L' -> L
    | _   -> failwith ("bad direction: " ^ s) (* In the case the input is bad *)
  in
  (* Start parsing for steps *)
  let steps =
    try
      let n = int_of_string steps_str in
        n
    with
    | Failure _ -> failwith ("bad steps: " ^ s)
  in
  { turn; steps }






(* Read through the entire file line by line and calls parse_line() *)
let read_instructions filename =
  let ic = open_in filename in
  let rec loop acc =
    try
      let line = input_line ic in
      let line = String.trim line in
      let acc =
        if line = "" then acc
        else parse_line line :: acc
      in
      loop acc
    with
    | End_of_file ->
        close_in ic;
        List.rev acc
  in
  loop []



(* DEBUGGING *)
(* DEBUGGING *)
(* DEBUGGING *)

(* Debugging to make sure input.txt parsing is correct *)
(* Convert from type turn = R | L to the chars 'R' or 'L' *)
(* let string_of_turn = function
  | R -> 'R'
  | L -> 'L'
 
let print_instr (i : instr) =
  print_char (string_of_turn i.turn);
  print_int i.steps;
  print_newline () *)

(* DEBUGGING *)
(* DEBUGGING *)
(* DEBUGGING *)



(* Turns the value of read_instructions() into an array *)
let data : instr array = Array.of_list (read_instructions file)

let () =
  Printf.printf "\n=== Software (mainPartOne.ml) ===\n\n";
  let zeros = ref 0 in                                  (* Number of zeros start at 0 *)
  let position = ref 50 in                              (* Position starts at 50 *)
  Printf.printf "Initial: position=50, zeros=0\n\n";
  for i = 0 to Array.length data - 1 do
    let {turn = t; steps = s} = data.(i) in
    if t = R then
      position := !position + s                         (* If steps is positive, then add to the position *)
    else
      position := !position - s;                        (* If steps is negative, then subtract from the position *)
   
    (* 
      We need to make sure position is bounded between 0 and 99
        - If the position is positive:
            position = position % 100 (simple)
        - If the position is negative:
            position = -106
            position = (position % 100) = -6; results in a negative value
            position = position + 100 = 94; results in a positive value
            position = position % 100 = 6; basically resulting in the absolute value of the first computation

      We can do:
        position = abs(position % 100)

      But this will only work for negative values, whereas the original algo works with positive values.
    *)
    position := ((!position mod 100) + 100) mod 100;

    (* If position is equal to 0 then we increment *)
    if !position = 0 then
      incr zeros;
    
    (* Print every instruction *)
    Printf.printf "Instr %4d: %c%-3d -> position=%2d, zeros=%d\n"
      (i + 1)
      (if t = R then 'R' else 'L')
      s
      !position
      !zeros
  done;

  (* Prints the answer *)
  Printf.printf "\nFinal Answer: %d\n" !zeros;
  print_newline ();




(* let () =
  let ic = open_in file in
  try
    let line = input_line ic in
    print_endline line;
    flush stdout;
    close_in ic
  with e ->
    close_in_noerr ic;
    raise e *)

