"Advent of FPGA/Hardcaml 2025"
===========================


This repository is built on hardcaml-template-project's starter template for getting started with Hardcaml, including:

- An RTL design that accepts a stream of numbers and calculates the range of the values,
  including use of the Always DSL to construct a state-machine
- A testbench, including waveform printing and VCD export using `hardcaml_test_harness`
<!-- - A binary to generate RTL for synthesis -->

## Running the testbench for the Example Project

To build the project, clone this repository and then run the following command, which will run the tests.

```
dune runtest
```

To validate that the tests are running, try changing one of the input values in
`day1a_test.ml` or `day1b_test` and re-running the tests, to see if the printed values change. Once
`dune` shows a diff in the tests, it can be accepted using the following command (this
will modify the file in-place, so you may need to close and re-open it):

```
dune runtest --auto-promote
```

## Installing Hardcaml

Hardcaml can be installed with opam. We highly recommend using Hardcaml with OxCaml (a
bleeding-edge OCaml compiler), which includes some Jane Street compiler extensions and
maintains the latest version of Hardcaml; while still maintaining direct compatibility
with existing OCaml code and libraries. Note that when looking at Hardcaml GitHub
repositories, the OxCaml version is in a branch named `with-extensions`.

Install [opam, the OxCaml compiler, and some basic developer
tools](https://oxcaml.org/get-oxcaml/) to get started.

For additional information on setting up the OCaml toolchain and editor support, see [Real
World OCaml](https://dev.realworldocaml.org/install.html).

Once it's set up, make sure you have the current switch selected in your shell:

```
opam switch 5.2.0+ox

eval $(opam env)
```

Then, install the core Hardcaml libraries and some other libraries used in Hardcaml projects:

```
opam install -y hardcaml hardcaml_test_harness hardcaml_waveterm ppx_hardcaml

opam install -y core core_unix ppx_jane rope re dune
```

## Solution

I have submitted hardcaml solutions to only day1 due to time constraints.
I have labelled the first part of day1 as day1a and the second part as day1b. There were two parts on AOC.

### day1a
We just have to count the number of times the dial is on 0 at the end of rotation.
The approach for day1a is slightly wrong. I have not implemented for the case where the rotation can be more than hundred.
- I add or subtract the rotation. Then adjust the current position of the dial to within 0 - 100 with one check.

The correct solution will involve using division from below. Not implementing due to time constraint.

### day1b
We have to count the total number of times the dial points to 0 even during rotation.
The approach for day1b had me implementing division by 100. N divided by 100 was implemented by multiplying with the ceil of 2^32 * 1/100. Then shifting to the right by 32 bits. My other thought was implementing around a 26 deep divider, where I constantly check for each 2^x * 100 whether the number is more or less, keep subtracting and modifying a counter (anyway, this is not too important).

```
let divide_by_100_32_bit (x : t) =
  let reciprocal = of_int_trunc ~width:32 42949673 in
  let shifted = srl (x *: reciprocal) ~by:32 in
  sel_bottom shifted ~width:32
```

The division was the most important part of the solution. Other parts are trivial.