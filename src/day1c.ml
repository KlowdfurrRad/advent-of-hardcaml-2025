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
    distance  : 'a; [@bits 32]   (* Explicit 8-bit width *)
  } [@@deriving sexp_of, hardcaml]
end

module O = struct
  type 'a t = {
    current_pos : 'a; [@bits 8]
    password  : 'a; [@bits 32]  (* Explicit 32-bit width *)
    total_passes_counter : 'a; [@bits 32]
  } [@@deriving sexp_of, hardcaml]
end

(* Helper Logic: Calculates the next position based on current position and inputs *)
let calculate_next_pos (i : _ I.t) current_pos =
  let c32 val_ = Signal.of_int_trunc ~width:32 val_ in
  
  (* Logic for Right (Add) *)
  let next_r = current_pos +: i.distance in
  let next_r_wrapped = mux2 (next_r >=: c32 100) (next_r -: c32 100) next_r in

  (* Logic for Left (Subtract) *)
  let next_l = (current_pos +: c32 100) -: i.distance in
  let next_l_wrapped = mux2 (next_l >=: c32 100) (next_l -: c32 100) next_l in

  mux2 i.is_right next_r_wrapped next_l_wrapped

let divide_by_100_32_bit (x : t) =
  let reciprocal = of_int_trunc ~width:32 42949673 in
  let shifted = srl (x *: reciprocal) ~by:32 in
  sel_bottom shifted ~width:32

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
    ~reset_to:(Bits.of_int_trunc ~width:8 50)
    ~clear_to:(Signal.of_int_trunc ~width:8 50)
    ~f:(calculate_next_pos i)
  in

  (* let init_movement = mux2 (i.is_right) (c32 100 -: current_pos) current_pos in *)
  (* let available_movement = i.distance -: init_movement in *)
  (* let num_passes = divide_by_100_32_bit available_movement in *)

  (* let total_passes_counter = reg_fb spec
    ~enable:i.valid 
    ~width:32
    ~reset_to:(Bits.of_int_trunc ~width:8 50)
    ~clear_to:(Signal.of_int_trunc ~width:8 50)
    ~f:(fun d -> (d +: num_passes))
  in *)

  (* 2. Re-calculate Next Position for the Counter *)
  (* We need to know where the dial lands THIS cycle to count correctly. *)
  (* Since 'current_pos' is the register output, applying the logic gives us the Next state. *)
  let next_pos = calculate_next_pos i current_pos in

  (* 3. Counter Logic *)
  (* If the dial is about to land on 0, and input is valid, increment. *)
  let lands_on_zero = next_pos ==: c32 0 in
  
  let count = reg_fb spec ~enable:(i.valid &: lands_on_zero) ~width:32 ~f:(fun c -> 
    c +: (Signal.of_int_trunc ~width:32 1)
  ) in

  { O.current_pos = current_pos; O.password = count; O.total_passes_counter = count}