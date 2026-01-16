open Base
open Hardcaml
open Signal

(* Hardware Interface *)
module I = struct
  type 'a t = {
    clock     : 'a;
    clear     : 'a;
    valid     : 'a;             (* input data is valid this cycle *)
    is_right  : 'a;             (* 0 = Left (L), 1 = Right (R) *)
    distance  : 'a; [@bits 32]   (* Explicit 32-bit width *)
  } [@@deriving sexp_of, hardcaml]
end

module O = struct
  type 'a t = {
    total_passes_counter : 'a; [@bits 32]
  } [@@deriving sexp_of, hardcaml]
end

let divide_by_100_32_bit (x : t) =
  let reciprocal = of_int_trunc ~width:32 42949673 in
  let shifted = srl (x *: reciprocal) ~by:32 in
  sel_bottom shifted ~width:32

(* Helper Logic: Calculates the next position based on current position and inputs *)
let calculate_next_pos (i : _ I.t) current_pos =
  let c32 val_ = Signal.of_int_trunc ~width:32 val_ in
  
  let modulated_distance = i.distance -: (sel_bottom ((c32 100) *: (divide_by_100_32_bit i.distance)) ~width:32) in

  (* Logic for Right (Add) *)
  let next_r = current_pos +: modulated_distance in
  let next_r_wrapped = mux2 (next_r >=: c32 100) (next_r -: c32 100) next_r in

  (* Logic for Left (Subtract) *)
  let next_l = (current_pos +: c32 100) -: modulated_distance in
  let next_l_wrapped = mux2 (next_l >=: c32 100) (next_l -: c32 100) next_l in

  mux2 i.is_right next_r_wrapped next_l_wrapped

(* Main Circuit *)
let create (_ : Scope.t) (i : _ I.t) =
  let spec = Reg_spec.create ~clock:i.clock ~clear:i.clear () in
  let c32 val_ = Signal.of_int_trunc ~width:32 val_ in

  (* 1. Position Register *)
  (* We pass the calculation function directly to reg_fb. *)
  (* internal logic: next_state = f(current_state) *)
  let current_pos = reg_fb spec 
    ~enable:i.valid 
    ~width:32
    ~reset_to:(Bits.of_int_trunc ~width:32 50)
    ~clear_to:(Signal.of_int_trunc ~width:32 50)
    ~f:(calculate_next_pos i)
  in

  let init_movement = mux2 (i.is_right) (c32 100 -: current_pos) current_pos in
  let available_movement = c32 100 +: i.distance -: init_movement in
  let num_passes = divide_by_100_32_bit available_movement in
  let num_passes_final = mux2 (current_pos ==: c32 0) (mux2 (i.is_right) num_passes (num_passes -: c32 1)) num_passes in

  let total_passes_counter = reg_fb spec
    ~enable:i.valid 
    ~width:32
    ~reset_to:(Bits.of_int_trunc ~width:32 0)
    ~clear_to:(Signal.of_int_trunc ~width:32 0)
    ~f:(fun d -> (d +: num_passes_final))
  in

  { O.total_passes_counter = total_passes_counter}