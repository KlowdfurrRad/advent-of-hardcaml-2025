open Core
open Hardcaml
open Hardcaml_demo_project

(* --- Helper: Parse Input Line --- *)
let parse_instruction line =
  let line = String.strip line in
  if String.is_empty line then None
  else
    let direction_char = line.[0] in
    let distance_str = String.sub line ~pos:1 ~len:(String.length line - 1) in
    let distance = Int.of_string distance_str in
    let is_right = Char.equal direction_char 'R' in
    Some (is_right, distance)

(* --- The Expect Test --- *)
let%expect_test "Day 1: Secret Entrance" =
  (* 1. Setup Simulation *)
  let scope = Scope.create () in

  (* A. Create the Circuit *)
  let module C = Circuit.With_interface (Day1.I) (Day1.O) in
  let circuit = C.create_exn ~name:"day1" (Day1.create scope) in

  (* B. Create a GENERIC simulator *)
  let sim = Cyclesim.create circuit in

  (* C. Look up ports by name *)
  let in_valid     = Cyclesim.in_port sim "valid" in
  let in_is_right  = Cyclesim.in_port sim "is_right" in
  let in_distance  = Cyclesim.in_port sim "distance" in
  let in_clear     = Cyclesim.in_port sim "clear" in
  
  let out_password = Cyclesim.out_port sim "password" in

  (* 2. Reset *)
  Cyclesim.reset sim;
  in_clear := Bits.vdd;
  Cyclesim.cycle sim;
  in_clear := Bits.gnd;

  (* 3. Read File *)
  let lines = In_channel.read_lines "input.txt" in

  (* 4. Drive Simulation *)
  List.iter lines ~f:(fun line ->
    match parse_instruction line with
    | None -> ()
    | Some (is_right, dist) ->
      in_valid := Bits.vdd;
      in_is_right := (if is_right then Bits.vdd else Bits.gnd);
      in_distance := Bits.of_int_trunc ~width:8 dist;
      Stdio.printf "Current Password: %d\n" (Bits.to_int_trunc !out_password);
      Cyclesim.cycle sim
  );

  (* 5. Settle *)
  in_valid := Bits.gnd;
  Cyclesim.cycle sim;
  Cyclesim.cycle sim;

  (* 6. Print Result *)
  (* FIX: Use to_int_trunc instead of to_int *)
  let final_password = Bits.to_int_trunc !out_password in
  Stdio.printf "Secret Password: %d\n" final_password;

  (* 7. Expectation *)
  (* Run with 'dune runtest --auto-promote' to populate this *)
  [%expect {| |}]