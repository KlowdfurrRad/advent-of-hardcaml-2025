open! Core
open! Hardcaml
open! Hardcaml_demo_project

let generate_day1_rtl () =
  let module C = Circuit.With_interface (Day1.I) (Day1.O) in
  (* Create a scope for signal naming *)
  let scope = Scope.create ~auto_label_hierarchical_ports:true () in
  (* Create the circuit using Day1 logic *)
  let circuit = C.create_exn ~name:"day1_top" (Day1.create scope) in
  
  (* Print Verilog to standard output *)
  Rtl.print Verilog circuit
;;

let day1_command =
  Command.basic
    ~summary:"Generate Verilog for AoC 2025 Day 1"
    [%map_open.Command
      let () = return () in
      fun () -> generate_day1_rtl ()]
;;

let () =
  Command_unix.run
    (Command.group ~summary:"Hardcaml AoC Generators" 
       [ "day1", day1_command ])
;;