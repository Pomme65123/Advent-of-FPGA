open Hardcaml
open Signal



(*
  Each input data is associated with a char followed by an integer.
  There can only exist two char values: 'R' and 'L'
 
  Setting turn to R | L makes it easier to read
  instr holds two values: turn and steps for the input type: <char><int>
*)
type turn = R | L
type instr = { 
  turn : turn;
  steps : int 
}




(* Improved function from mainPartOne.ml (1 dir lower) *)
let read_instructions filename =
  let ic = open_in filename in
  let rec loop acc =
    try
      let line = input_line ic in
      let line = String.trim line in
      if line = "" then loop acc
      else
        let dir = if line.[0] = 'R' then R else L in
        let steps = int_of_string (String.sub line 1 (String.length line - 1)) in
        loop ({ turn = dir; steps } :: acc)
    with End_of_file ->
      close_in ic;
      List.rev acc
  in
  loop []
;;




let create_circuit () =
  let clock = input "clock" 1 in
  let reset = input "reset" 1 in
  let position, zeros = PartTwo_hardcaml.create ~clock ~reset in
  Circuit.create_exn ~name:"position_tracker"
    [ output "position" position
    ; output "zeros" zeros
    ]
;;

let () =
  let instructions = read_instructions "../input.txt" in
  
  let circuit = create_circuit () in
  let sim = Cyclesim.create circuit in
  

  
  Cyclesim.in_port sim "reset" := Bits.vdd;
  Cyclesim.in_port sim "enable" := Bits.gnd;
  Cyclesim.in_port sim "turn" := Bits.of_int ~width:1 0;
  Cyclesim.in_port sim "steps" := Bits.of_int ~width:10 0;
  Cyclesim.cycle sim;
  

  
  Cyclesim.in_port sim "reset" := Bits.gnd;
  
  List.iter (fun instr ->
    Cyclesim.in_port sim "turn" := Bits.of_int ~width:1 (if instr.turn = R then 1 else 0);
    Cyclesim.in_port sim "steps" := Bits.of_int ~width:10 instr.steps;
    Cyclesim.in_port sim "enable" := Bits.vdd;
    Cyclesim.cycle sim;
  ) instructions;
  
  let final_pos = Bits.to_int !(Cyclesim.out_port sim "position") in
  let final_zeros = Bits.to_int !(Cyclesim.out_port sim "zeros") in
  
  Printf.printf "Position: %d\n" final_pos;
  Printf.printf "Zeros: %d\n" final_zeros;
;;