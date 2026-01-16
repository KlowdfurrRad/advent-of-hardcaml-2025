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