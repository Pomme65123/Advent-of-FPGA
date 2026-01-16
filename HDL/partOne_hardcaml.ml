open Hardcaml
open Signal

let position_width = 12      (* Maximum number of steps is 999. This means position max is 1098 and -999. 12 bits will cover all cases. *)
let steps_width = 10         (* We only need 10 bits because the output of find_largest_steps.py: Line 4482: R999 *)
let zero_count_width = 13    (* There are 4762 lines of inputs from input.txt. 13 bits will cover all cases.*)



(* 
    Problem with HDL:
      - Division operations != 2
      - Modulous operations != 2
    
    No reason to use either when we are dealing with whole numbers so subtraction and addition it is!
*)
let normalize_position pos =
  let val_100 = of_int ~width:position_width 100 in
  let val_99 = of_int ~width:position_width 99 in
  
  let rec loop pos iterations =
    if iterations = 0 then pos
    else
      let too_high = pos >+ val_99 in         (*  too_high = pos > 99 ? true : false *)
      let too_low = msb pos in                (* Assigned to the signed bit of pos *)
      
      let adjusted = 
        mux2 
          too_high (pos -: val_100)           (* adjusted = pos > 99 ? pos -= 100 : pos = pos *)
          (mux2 too_low (pos +: val_100) pos) (* adjusted = pos < 0 ? pos += 100 : pos = pos*)
      in
      loop adjusted (iterations - 1)
  in
  loop pos 11  (* Since the min/max position is -999 and 1098 respectively, only need 11 iterations to cover: (+/- (11 * 100))*)
;;



let create ~clock ~reset =
  let spec = Reg_spec.create ~clock ~reset () in
  
  (* Inputs *)
  let enable = input "enable" 1 in
  let turn = input "turn" 1 in
  let steps = input "steps" steps_width in
  

  let steps_ext = uresize steps position_width in     (* I thought making everything the same bits would be easier. It is not lol *)
  

  let init_pos = of_int ~width:position_width 50 in   (* Initial Position = 50 *)
  let init_zeros = zero zero_count_width in           (* Initial Zeros = 0*)
  


  let state_width = zero_count_width + position_width in
  let state =
    reg_fb spec ~enable:vdd ~width:state_width ~f:(fun s ->
      
      (* Wanted to try the nibble functions *)
      let pos = sel_bottom s position_width in
      let count = sel_top s zero_count_width in
      
      (* Reset logic *)
      let pos_curr = mux2 reset init_pos pos in
      let count_curr = mux2 reset init_zeros count in
      
      mux2 enable
        (
          let delta = mux2 turn steps_ext (negate steps_ext) in   (* delta = (turn) ? steps_ext : !steps_ext. I use R = 1 and L = 0 *)
          let new_pos = pos_curr +: delta in                      (* adding position with number of steps *)
          let norm_pos = normalize_position new_pos in            (* calling normalize_position() to bound between 0~99 *)

          (* If the resulting position is 0, we increment the counter *)
          let is_zero = norm_pos ==:. 0 in
          let new_count = mux2 is_zero (count_curr +:. 1) count_curr in
          
          concat_msb [ new_count; norm_pos ]
        )
        (concat_msb [ count_curr; pos_curr ])
    )
  in
  


  let position = sel_bottom state position_width in
  let zeros = sel_top state zero_count_width in
  
  (position, zeros)   (* Doesn't need to return a tuple, but made debugging easier *)
;;
