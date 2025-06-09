

// lines 1,4,5,6,7 have delayed execution
`define BINARY_PUSH_L0 (PCCHasASR && `INSTR == instr_lines[0] && finishing_executed)
`define BINARY_PUSH_L1 (`INSTR == instr_lines[1] ##1 finishing_executed)
`define BINARY_PUSH_L2 (`INSTR == instr_lines[2] && finishing_executed)
`define BINARY_PUSH_L3 (`INSTR == instr_lines[3] && finishing_executed)
`define BINARY_PUSH_L4 (`INSTR == instr_lines[4] ##1 finishing_executed)
`define BINARY_PUSH_L5 (`INSTR == instr_lines[5] ##1 finishing_executed)
`define BINARY_PUSH_L6 (`INSTR == instr_lines[6] ##1 finishing_executed)
`define BINARY_PUSH_L7 (`INSTR == instr_lines[7] ##1 finishing_executed)

// lines 1,3,4,5,6,7 force delay of ##3 (irrelevant for l7)
// Macro for binary push through until each line (l1 to l7)
`define BINARY_PUSH_UNTIL_L1 (`BINARY_PUSH_L0 ##1 `BINARY_PUSH_L1)
`define BINARY_PUSH_UNTIL_L2 (`BINARY_PUSH_UNTIL_L1 ##3 `BINARY_PUSH_L2)
`define BINARY_PUSH_UNTIL_L3 (`BINARY_PUSH_UNTIL_L2 ##1 `BINARY_PUSH_L3)
`define BINARY_PUSH_UNTIL_L4 (`BINARY_PUSH_UNTIL_L3 ##3 `BINARY_PUSH_L4)
`define BINARY_PUSH_UNTIL_L5 (`BINARY_PUSH_UNTIL_L4 ##3 `BINARY_PUSH_L5)
`define BINARY_PUSH_UNTIL_L6 (`BINARY_PUSH_UNTIL_L5 ##3 `BINARY_PUSH_L6)
`define BINARY_PUSH_UNTIL_L7 (`BINARY_PUSH_UNTIL_L6 ##3 `BINARY_PUSH_L7)

// Macro for the full sequence
`define BINARY_PUSH_THROUGH ( \
`BINARY_PUSH_L0 ##1 \
`BINARY_PUSH_L1 ##3 \
`BINARY_PUSH_L2 ##1 \
`BINARY_PUSH_L3 ##3 \
`BINARY_PUSH_L4 ##3 \
`BINARY_PUSH_L5 ##3 \
`BINARY_PUSH_L6 ##3 \
`BINARY_PUSH_L7 )

parameter DELAY = 22;

reg_cap_t csp_at_entry;
logic [31:0] csp_addr_at_entry;
always @(posedge clk_i ) begin
csp_at_entry <= $past(csp, DELAY-1);
csp_addr_at_entry <= $past(csp_addr, DELAY-1);
end
// -------------------------------------------------------------------------
// 
not_immediate2: assert property(
    PCCHasASR && 
        `INSTR == 32'h03d1005b && finishing_executed 
    ##1 `INSTR == 32'h00013383
    |-> ~finishing_executed
);
waittime2: assert property (
        PCCHasASR && 
        `INSTR == 32'h03d1005b && finishing_executed 
    ##1 `INSTR == 32'h00013383
    ##1 finishing_executed
    |-> (~instr_will_progress)[*2] and (`INSTR == 32'h00013383)[*3]
);
consistency2: assert property (
        PCCHasASR && 
        `INSTR == 32'h03d1005b && finishing_executed 
    ##1 `INSTR == 32'h00013383 
    ##1 finishing_executed
    ##3 `INSTR == 32'h08812083 
    |-> (($past(`INSTR,4) == 32'h00013383)[*4] and $past(~instr_will_progress,4)[*3])
);
// -----------------------------------------------------------------------------------------

// -----------------------------------------------------------------------------------------
// delay at line 4-5: csrw -> cspecialw
// no delay at executing, 2 cycles delay in progression stage
waittime4: assert property (
        PCCHasASR && 
        `INSTR == 32'h03d1005b && finishing_executed 
    ##1 `INSTR == 32'h00013383 
    ##1  finishing_executed 
    ##3 `INSTR == 32'h08812083 && finishing_executed
    ##1 `INSTR == 32'h30009073 && finishing_executed
    |-> (~instr_will_progress)[*2] and (`INSTR == 32'h30009073)[*3]
);
consistency4: assert property (
        PCCHasASR && 
        `INSTR == 32'h03d1005b && finishing_executed 
    ##1 `INSTR == 32'h00013383 
    ##1 finishing_executed
    ##3 `INSTR == 32'h08812083
    ##1  finishing_executed
    ##1 `INSTR == 32'h30009073 && finishing_executed
    ##3 `INSTR == 32'h03f3805b
    |-> (($past(`INSTR,3) == 32'h30009073)[*3] and $past(~instr_will_progress,3)[*2])
);
// ----------------------------------------------------------------------------------------


// ---------------------------------------------------------------------------------------
// delay at line 6-7: clc -> clc
// 1 cycle delay to execute, 2 cycles in progression stage
not_immediate6: assert property(
        PCCHasASR && 
        `INSTR == 32'h03d1005b && finishing_executed 
    ##1 `INSTR == 32'h00013383 
    ##1 finishing_executed
    ##3 `INSTR == 32'h08812083
    ##1  finishing_executed
    ##1 `INSTR == 32'h30009073 && finishing_executed
    ##3 `INSTR == 32'h03f3805b && finishing_executed
    ##1 `INSTR == 32'h00813083
    |-> ~finishing_executed
);
waittime6: assert property (
        PCCHasASR && 
        `INSTR == 32'h03d1005b && finishing_executed 
    ##1 `INSTR == 32'h00013383 
    ##1 finishing_executed
    ##3 `INSTR == 32'h08812083
    ##1  finishing_executed
    ##1 `INSTR == 32'h30009073 && finishing_executed
    ##3 `INSTR == 32'h03f3805b && finishing_executed
    ##1 `INSTR == 32'h00813083
    ##1 finishing_executed
    |-> (~instr_will_progress)[*2]
);
consistency6: assert property (
        PCCHasASR && 
        `INSTR == 32'h03d1005b && finishing_executed 
    ##1 `INSTR == 32'h00013383 
    ##1  finishing_executed
    ##3 `INSTR == 32'h08812083
    ##1  finishing_executed
    ##1 `INSTR == 32'h30009073 && finishing_executed
    ##3 `INSTR == 32'h03f3805b && finishing_executed
    ##1 `INSTR == 32'h00813083
    ##1 finishing_executed
    ##3 `INSTR == 32'h03813383
    |-> (($past(`INSTR,4) == 32'h00813083)[*4] and $past(~instr_will_progress,4)[*3])
);


// // ----------- Proofs that lines 1, 5, 6, 7 do not finish execution immediately ---------------------- //
// // a clc instruction (l1, l5, l6, l7) does not finish immediately 
// clc_not_immediate: assert property(
//         finishing_executed
//     ##1 `IS_CLC && ~wbexc_illegal && `INSTR != $past(`INSTR)
//     |-> ~finishing_executed ##1 `INSTR == $past(`INSTR) 
// );

// // l4 (cspecialw) does not finish immediately after being loaded into webx stage after the binary execution
// l4_not_immediate: assert property(
//         `BINARY_PUSH_UNTIL_L3
//     ##3 `INSTR == instr_lines[4] 
//     |-> ~finishing_executed ##1 `INSTR == $past(`INSTR) 
// );

// // ----------- Proofs that lines 1, 3,4,5, 6, 7 delay progression by 2 cycles ---------------------- //
// // a clc instruction takes at least 3 cycles after loading into wbexc stage
// clc_delay_progression: assert property(
//         finishing_executed
//     ##1 `IS_CLC && `INSTR != $past(`INSTR) 
//         && ~wbexc_fetch_err && ~wbexc_illegal 
//     |-> (~instr_will_progress)[*3] // delaying by 3 cycles 
// );

// // line 3 (csrw) and 4 (cspecialw) take at least 2 more cycles after loading into wbexc stage
// l3_delay_progression: assert property(
//         `BINARY_PUSH_UNTIL_L3
//     |-> (~instr_will_progress)[*2] 
// );
// l4_delay_progression: assert property(
//         `BINARY_PUSH_UNTIL_L4 
//     |-> (~instr_will_progress)[*2]  
// );
