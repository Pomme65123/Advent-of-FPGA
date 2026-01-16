# Advent of Code Day 1 - HardCAML Implementation

This directory contains HardCAML hardware circuit implementations for Advent of Code Day 1, converting the OCaml software solutions into synthesizable hardware designs.

## Overview

The circuits track a position on a circular track (0-99) and process R/L turn instructions with step counts:
- **Part One**: Counts how many times the position lands exactly on 0
- **Part Two**: Counts zero crossings, including when going through 0 during left turns and counting 100-boundary crossings

## Files

### HDL Directory
- `partOne_hardcaml.ml` - Part One circuit implementation
- `test_partOne_hardcaml.ml` - Part One test harness
- `partTwo_hardcaml.ml` - Part Two circuit implementation
- `test_partTwo_hardcaml.ml` - Part Two test harness
- `dune` - Build configuration

### Root Directory
- `mainPartOne.ml` - Original OCaml software implementation (Part One)
- `mainPartTwo.ml` - Original OCaml software implementation (Part Two)
- `input.txt` - **Required input file**

## Prerequisites

- **input.txt file** - Must be placed in the root directory (same level as HDL folder)

## Building

From the HDL directory:

```
cd ./HDL/
opam exec -- dune build
```

## Running

**Note**: Both test programs read from `../input.txt` (root directory). Ensure this file exists before running.

### Part One

From the HDL directory:
```
./_build/default/test_partOne_hardcaml.exe
```

### Part Two

From the HDL directory:
```
./_build/default/test_partTwo_hardcaml.exe
```

### Original Solutions

From the Root directory:
```
ocamlopt mainPartOne.ml
ocamlopt mainPartOne.cmx mainPartTwo.ml
./a.out
```

## Implementation Details

### Part One
- **Position width**: 12 bits (signed, range -2048 to 2047, covers -999 to 1098)
- **Steps width**: 10 bits (0-1023, actual max is 999)
- **Zero counter**: 13 bits (0-8191, sufficient for the input.txt instruction length)

### Part Two
- **Position width**: 12 bits (signed)
- **Steps width**: 10 bits
- **Zero counter**: 13 bits (0-8191, sufficient for my testcase, but can easily overflow)

### Logic

- **Combinational normalization**: Uses iterative add/subtract (11 iterations) to normalize position to [0,99] range
- **Integer division**: Implements division by 100 using repeated subtraction for Part Two (11 iterations)

## Circuit Architecture

Both circuits use:
- Clock and reset inputs
- Enable signal for processing control
- Turn signal (R = 1, L = 0)
- Steps input (10 bits)
- Position and zeros outputs

The main state is stored in a combined register to avoid timing issues between separate registers.

**Note**: The `input.txt` file is not included in the repository (see `.gitignore`). You must provide your own input file from Advent of Code Day 1.
