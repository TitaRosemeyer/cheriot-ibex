/*
This file is the top-level module for the TITA formal verification environment.
Here, we define the main functionality and properties we want to verify.

It uses tita_registers.sv for register definitions and tita_cap_overlap.sv for capability overlap checks.
This file is included in top.sv which is the main entry point for the formal verification.

*/
`define INSTR_WB(instr) \
    wbexc_exists && ~wbexc_fetch_err && `INSTR == instr

`define INSTR_LIFECYCLE \
    ((instr_will_progress) or ((~instr_will_progress)[*1:2] ##1 instr_will_progress))

// same as instr_lifecycle but with concrete delay -> only works for n >= 1
`define INSTR_DELAY(n) \
    ((~instr_will_progress)[*n] ##1 instr_will_progress)


// Include helper files
`include "tita_helpers/tita_registers.sv"
`include "tita_helpers/tita_cap_overlap.sv" 
`include "tita_helpers/tita_delay_buffer.sv"
`include "tita_helpers/decoding_correctness.sv"

`include "switcher.sv"