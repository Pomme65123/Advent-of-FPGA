open Hardcaml
open Signal


let position_width = 12      (* Maximum number of steps is 999. This means position max is 1098 and -999. 12 bits will cover all cases. *)
let steps_width = 10         (* We only need 10 bits because the output of find_largest_steps.py: Line 4482: R999 *)
let zero_count_width = 13    (* This fulfills the requirements for the answer, but oviously this can easily overflow with othre datasets *)



(* Copied from partOne_hardcaml.ml *)
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



(* Alternative for abs(position / 100) *)
let count_hundreds pos =
  let val_100 = of_int ~width:position_width 100 in
  let val_99 = of_int ~width:position_width 99 in
  
  let pos_abs = mux2 (msb pos) (negate pos) pos in    (* abs() equivalent *)
  
  (* Starts counting the amount of times we cross the 0 line *)
  let rec loop pos_remaining count iterations =
    if iterations = 0 then count
    else
      let can_subtract = pos_remaining >+ val_99 in
      let new_count = mux2 can_subtract (count +:. 1) count in
      let new_remaining = mux2 can_subtract (pos_remaining -: val_100) pos_remaining in
      loop new_remaining new_count (iterations - 1)
  in
  loop pos_abs (zero zero_count_width) 11
;;



let create ~clock ~reset =
  let spec = Reg_spec.create ~clock ~reset () in
  
  (* Inputs *)
  let enable = input "enable" 1 in
  let turn = input "turn" 1 in
  let steps = input "steps" steps_width in
  
  let steps_ext = uresize steps position_width in (* I thought making everything the same bits would be easier. It is not lol *)
  

  let init_pos = of_int ~width:position_width 50 in   (* Initial Position = 50 *)
  let init_zeros = zero zero_count_width in           (* Initial Zeros = 0*)
  


  let state_width = zero_count_width + position_width in
  let state =
    reg_fb spec ~enable:vdd ~width:state_width ~f:(fun s ->

      let pos = sel_bottom s position_width in
      let count = sel_top s zero_count_width in
      
      (* Reset logic *)
      let pos_curr = mux2 reset init_pos pos in
      let count_curr = mux2 reset init_zeros count in
      
      mux2 enable
        (
          (* 
            For L turns only
              - if L turn
                - L turns are pure subtractions
              - if current position is less than steps
                - this is an automatic cross
              - if current position is not 0
                - this always means current position < steps, but this is not a cross
          *)
          let is_left_turn = ~:turn in
          let will_cross_zero = (is_left_turn &: (pos_curr <>:. 0) &: (pos_curr <+ steps_ext)) in
          let count_after_crossing = mux2 will_cross_zero (count_curr +:. 1) count_curr in
          
          let delta = mux2 turn steps_ext (negate steps_ext) in   (* delta = (turn) ? steps_ext : !steps_ext. I use R = 1 and L = 0 *)
          let new_pos = pos_curr +: delta in                      (* adding position with number of steps *)
          

          
          let is_zero = new_pos ==:. 0 in
          
          mux2 is_zero
            (concat_msb [ count_after_crossing +:. 1; zero position_width ])

            (
              let num_hundreds = count_hundreds new_pos in
              let count_with_hundreds = count_after_crossing +: num_hundreds in
              let norm_pos = normalize_position new_pos in
              
              concat_msb [ count_with_hundreds; norm_pos ]
            )
        )
        (concat_msb [ count_curr; pos_curr ])
    )
  in

  let position = sel_bottom state position_width in
  let zeros = sel_top state zero_count_width in
  
  (position, zeros)   (* Doesn't need to return a tuple, but made debugging easier *)
;;