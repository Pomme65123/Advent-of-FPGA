(* 
  From the mainPartOne.ml we use
    - type turn = R | L
    - type instr = {
        turn  : turn;
        steps : int;
      }
    - read_instructions()
*)

type turn   = MainPartOne.turn
type instr  = MainPartOne.instr



(* 
  Input file is called input.txt in this case
  read_instructions() parses the file line by line
*)
let file = "input.txt"
let data : instr array = Array.of_list (MainPartOne.read_instructions file)

let () =
  let zeros     = ref 0 in
  let position  = ref 50 in
  for i = 0 to Array.length data - 1 do
    let {MainPartOne.turn = t; steps = s} = data.(i) in

    (* Debugging *)
    (* Debugging *)
    (* Debugging *)
    (* Printf.printf "i=%d BEFORE: zeros=%d position=%d turn=%c steps=%d\n"
      i !zeros !position
      (match t with R -> 'R' | L -> 'L') s; *)
    (* Debugging *)
    (* Debugging *)
    (* Debugging *)

    (* 
      Obviously the position can increase or decrease with the amount of steps.
      The special cases are:
        - If the position ends up at 0 during an L turn: 
            position = 50, L50 = position 0
            incr zeros
        - If the position is less than the steps on an L turn:
            position = 3, L4 = position -1
            incr zeros
    *)
    if t = MainPartOne.R then
      position := !position + s
    else begin
      if !position != 0 && !position < s then incr zeros;
      position := !position - s;
    end;

    (* 
      This solves the first special case:
        - If the position ends up at 0 during an L turn: 
            (position = 50, t,s = L,50) = position 0
            incr zeros
      
      If this occurs, then we don't need to recalculate additional zeros because position can never end up greater than 99.
      If it doesn't occur, we find the absolute value of (int)(position / 100) as this tells us the amount of zero crossings.
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
    if !position = 0 then
      incr zeros
    else begin
      zeros := !zeros + abs (!position / 100);
      position := (((!position mod 100) + 100) mod 100);
    end;

    (* Debugging *)
    (* Debugging *)
    (* Debugging *)
    (* Printf.printf "i=%d AFTER : zeros=%d position=%d\n\n"
      i !zeros !position *)
    (* Debugging *)
    (* Debugging *)
    (* Debugging *)
  done;

  (* 
    Prints the answer.
  *)
  Printf.printf "\nPart Two Answer: %d\n" !zeros;
  print_newline ();  