/*
This file is the top-level module for the TITA formal verification environment.
Here, we define the main functionality and properties we want to verify.

It uses tita_registers.sv for register definitions and tita_cap_overlap.sv for capability overlap checks.
This file is included in top.sv which is the main entry point for the formal verification.

Module tita is the overarching module that contains all the properties and checks we want to verify.
Its submodules include instructions (properties related to instruction execution) and test (for testing on simple examples).
*/


// Include helper files
`include "tita_helpers/tita_registers.sv"
`include "tita_helpers/tita_cap_overlap.sv" 
`include "tita_helpers/tita_delay_buffer.sv"

//----------------------------------------------------------
// Defining the instruction lines 
//----------------------------------------------------------

// Define a property for instruction decoding correctness
property instruction_decoding_correctness(logic [31:0] instr_in, logic [31:0] instr_out);
    (`CR.if_stage_i.compressed_decoder_i.instr_i == instr_in && instr_will_progress)
    |-> (`IF.instr_out == instr_out);
endproperty

// clc_ct2_00_decoding:    assert property (instruction_decoding_correctness(32'h6382, 32'h00013383));
// clw_ra_88_decoding:     assert property (instruction_decoding_correctness(32'h40aa, 32'h08812083));
// clc_cra_08_decoding:    assert property (instruction_decoding_correctness(32'h60a2, 32'h00813083));
// clc_ct2_38_decoding:    assert property (instruction_decoding_correctness(32'h73e2, 32'h03813383));
// clc_csp_10_decoding:    assert property (instruction_decoding_correctness(32'h6142, 32'h01013103));

// These instruction lines are taken from tita_binaries.txt, which contains parts of a dump from the relevant switcher code.
// The instructions are given in decompressed form, and the comments indicate the original compressed instruction and its meaning.
logic [31:0] instr_lines [8] = '{
    32'h03d1005b, // l0 03d1005b    cspecialw	mtdc, csp
    32'h00013383, // l1 6382        clc	ct2, 0x0(csp)    
    32'h08812083, // l2 40aa        clw	ra, 0x88(csp)
    32'h30009073, // l3 30009073    csrw	mstatus, ra
    32'h03f3805b, // l4 03f3805b    cspecialw	mepcc, ct2
    32'h00813083, // l5 60a2        clc	cra, 0x8(csp)
    32'h03813383, // l6 73e2        clc	ct2, 0x38(csp)
    32'h01013103  // l7 6142        clc	csp, 0x10(csp)
};




//----------------------------------------------------------
// start of the main module
//----------------------------------------------------------
module tita;

    // do some sanity checks on the overlap functions
    logic [32:0] csp_top = get_top_bound33(csp, csp_addr);
    logic [31:0] csp_base = get_base_bound32(csp, csp_addr);
    BoundsSanityCheck: assert property (csp.valid && csp.exp != 5'd24 |-> csp_top >= csp_base); 
    // somehow top < base is allowed for capabilities with exp == 24
    BigCapBounds: assert property (csp.valid && csp.exp == 5'd24 |-> csp_top >= csp_base); 
    OverlapSanityCheck: assert property (csp_top >= csp_base |-> overlap(csp,csp_addr, csp, csp_addr));

    // prevent clc instructions from raising exceptions
    // csp.valid set, csp unsealed, csp grants PERMIT_LOAD, 
    // csp.addr + imm >= csp_base, csp.addr + imm + CLEN/8 <= csp_top for 0 <= imm <=0x88
    // csp.addr + imm is aligned to CLEN/8, for imm = 0 mod 8
    // I assume CLEN is 64 bits, so CLEN/8 = 8 bytes (cap_size in the manual)
    logic csp_unsealed = csp.otype == 3'b000;
    logic csp_has_permit_load = csp.cperms[4:3] == 2'b11 | csp.cperms[4:2] == 3'b101 | csp.cperms[4:1] == 4'b1001 | csp.cperms[4:3] == 2'b01;
    logic csp_addr_in_bounds = (csp_addr >= csp_base) && (csp_addr + 32'h88 + 32'h8 <= csp_top);
    logic csp_addr_aligned = (csp_addr % 8 == 0); // assuming CLEN is 64
    logic csp_assumptions = csp.valid && csp_unsealed && csp_has_permit_load && csp_addr_in_bounds && csp_addr_aligned;

    
    logic PCCHasASR = (pcc.cperms[4:2] == 3'b011);

   
    

    module instructions;
        //----------------------------------------------------------
        // Defining overlap functions with registers and memory
        //----------------------------------------------------------

        // Defining overlap functions with registers
        `CAPNOOVERLAPREGS_FN(no_overlap_all_fn, 1)
        `CAPNOOVERLAPREGS_FN(no_overlap_except2_fn, i != 2)

        // Shorthand for overlap of csp capabilities with registers
        logic csp_no_overlap_except2 = no_overlap_except2_fn(csp, csp_addr);
        logic csp_at_entry_no_overlap_all = no_overlap_all_fn(csp_at_entry, csp_addr_at_entry);
        logic csp_at_entry_no_overlap_except2 = no_overlap_except2_fn(csp_at_entry, csp_addr_at_entry);

        `define CPU_WB_PATH  ibex_top_i.u_ibex_core.wb_stage_i
        reg_cap_t lsu_cap_i = `CPU_WB_PATH.rf_wcap_lsu_i;
        logic [31:0] lsu_addr_i = `CPU_WB_PATH.rf_wdata_lsu_i;

        logic csp_no_memory_overlap = ~overlap(csp, csp_addr, lsu_cap_i , lsu_addr_i);
        logic csp_at_entry_no_memory_overlap = ~overlap(csp_at_entry, csp_addr_at_entry, lsu_cap_i, lsu_addr_i);

        

        //----------------------------------------------------------
        // New idea: using a delay buffer of instr_will_progress 
        //----------------------------------------------------------

        `define INSTR_WB(i) \
            wbexc_exists && ~wbexc_fetch_err && `INSTR == instr_lines[i] 
        
        `define INSTR_LIFECYCLE \
            ((instr_will_progress) or ((~instr_will_progress)[*1:2] ##1 instr_will_progress))


        property line_0_prop;
            (((PCCHasASR && csp_assumptions && `INSTR_WB(0)) and
            `INSTR_LIFECYCLE)
            |-> mtdc == csp_at_entry && mtdc_addr == csp_addr_at_entry
            );
        endproperty
        line_0: assert property (line_0_prop);

        property lines_0_1_prop;
            (((PCCHasASR && csp_assumptions && `INSTR_WB(0)) and
            `INSTR_LIFECYCLE)
            ##1
            (`INSTR_WB(1) and
            (csp_at_entry_no_memory_overlap throughout `INSTR_LIFECYCLE))
            |-> mtdc == csp_at_entry && mtdc_addr == csp_addr_at_entry 
            ##1 ~overlap(ct2, ct2_addr, $past(csp_at_entry), $past(csp_addr_at_entry)) 
            
            );
        endproperty
        lines_0_1: assert property (lines_0_1_prop);

        property lines_0_2_prop;
            (((PCCHasASR && csp_assumptions && `INSTR_WB(0)) and
            `INSTR_LIFECYCLE)
            ##1
            (`INSTR_WB(1) and
            (csp_at_entry_no_memory_overlap throughout `INSTR_LIFECYCLE))
            ##1
            (`INSTR_WB(2) and `INSTR_LIFECYCLE)
            |-> mtdc == csp_at_entry && mtdc_addr == csp_addr_at_entry 
            && ~overlap(csp_at_entry, csp_addr_at_entry, ct2, ct2_addr)
            );
        endproperty
        lines_0_2: assert property (lines_0_2_prop);

        property lines_0_3_prop;
            (((PCCHasASR && csp_assumptions && `INSTR_WB(0)) and
            `INSTR_LIFECYCLE)
            ##1
            (`INSTR_WB(1) and
            (csp_at_entry_no_memory_overlap throughout `INSTR_LIFECYCLE))
            ##1
            (`INSTR_WB(2) and `INSTR_LIFECYCLE)
            ##1
            (`INSTR_WB(3) and `INSTR_LIFECYCLE)
            |-> mtdc == csp_at_entry && mtdc_addr == csp_addr_at_entry 
            && ~overlap(csp_at_entry, csp_addr_at_entry, ct2, ct2_addr)
            );
        endproperty
        lines_0_3: assert property (lines_0_3_prop);

        property lines_0_4_prop;
            (((PCCHasASR && csp_assumptions && `INSTR_WB(0)) and
            `INSTR_LIFECYCLE)
            ##1
            (`INSTR_WB(1) and
            (csp_at_entry_no_memory_overlap throughout `INSTR_LIFECYCLE))
            ##1
            (`INSTR_WB(2) and `INSTR_LIFECYCLE)
            ##1
            (`INSTR_WB(3) and `INSTR_LIFECYCLE)
            ##1
            (`INSTR_WB(4) and `INSTR_LIFECYCLE)
            |-> mtdc == csp_at_entry && mtdc_addr == csp_addr_at_entry
            && ~overlap(csp_at_entry, csp_addr_at_entry, ct2, ct2_addr)
            && mepcc == ct2 && mepcc_addr == ct2_addr 
            );
        endproperty
        // lines_0_4: assert property (lines_0_4_prop);
        
        // same as instr_lifecycle but with concrete delay
        `define INSTR_DELAY(n) \
            ((~instr_will_progress)[*n-1] ##1 instr_will_progress)
        
        property all_lines_concrete_delay_prop;
            (
            csp_at_entry_no_memory_overlap throughout
            (((PCCHasASR && csp_assumptions && `INSTR_WB(0)) and
            `INSTR_DELAY(2))
            ##1
            (`INSTR_WB(1) and (instr_will_progress))
            ##1
            (`INSTR_WB(2) and `INSTR_DELAY(2))
            ##1
            (`INSTR_WB(3) and `INSTR_DELAY(3))
            ##1
            (`INSTR_WB(4) and `INSTR_DELAY(2))
            ##1
            (`INSTR_WB(5) and `INSTR_DELAY(2))
            ##1
            (`INSTR_WB(6) and `INSTR_DELAY(2))
            ##1
            (`INSTR_WB(7) and (instr_will_progress)))
            |-> mtdc == csp_at_entry && mtdc_addr == csp_addr_at_entry 
            ##1 ~overlap($past(csp_at_entry), $past(csp_addr_at_entry), csp, csp_addr)
            && ~overlap($past(csp_at_entry), $past(csp_addr_at_entry), ct2, ct2_addr)
            && ~overlap($past(csp_at_entry), $past(csp_addr_at_entry), cra, cra_addr)
            );
        endproperty
        all_lines_concrete_delay: assert property (all_lines_concrete_delay_prop);
        

        //----------------------------------------------------------
        // Doing it the old way: checking which instruction is in `INSTR
        //----------------------------------------------------------
        property line_0_old_prop;
            (
            (csp_assumptions && PCCHasASR && wbexc_exists && ~wbexc_fetch_err) and
            (`INSTR == instr_lines[0])[*1:5]
            ##1
            instr_has_changed
            |-> $past(mtdc == csp_at_entry) &&
            $past(mtdc_addr == csp_addr_at_entry) 
        ); 
        endproperty
        // line_0_old: assert property (line_0_old_prop);

        property lines_0_1_old_prop;
            ((csp_assumptions && PCCHasASR && wbexc_exists && ~wbexc_fetch_err) and
            (`INSTR == instr_lines[0])[*1:5] 
            ##1 
            (`INSTR == instr_lines[1] && csp_at_entry_no_memory_overlap && ~wbexc_fetch_err)[*1:5] 
            ##1
            instr_has_changed
            |->  ~overlap($past(csp_at_entry), $past(csp_addr_at_entry), ct2, ct2_addr) 
        ); 
        endproperty
        // lines_0_1_old: assert property (lines_0_1_old_prop);


        //----------------------------------------------------------
        // Trying different versions of the whole code block
        //----------------------------------------------------------

        // these are the delays for the different stages of the pipeline, as observed in example executions
        parameter l0_delay = 2;
        parameter l1_delay = 1;
        parameter l2_delay = 2;
        parameter l3_delay = 3;
        parameter l4_delay = 2;
        parameter l5_delay = 2;
        parameter l6_delay = 2;
        parameter l7_delay = 1;

        // trying on the whole code block with concrete delays
        property push_through_prop;
            (
            (csp_assumptions && PCCHasASR && wbexc_exists) and
            (`INSTR == instr_lines[0])[*1:l0_delay] 
            ##1 
            (`INSTR == instr_lines[1] && csp_at_entry_no_memory_overlap)[*1:l1_delay] 
            ##1
            (`INSTR == instr_lines[2] && csp_at_entry_no_memory_overlap)[*1:l2_delay] 
            ##1
            (`INSTR == instr_lines[3])[*1:l3_delay] 
            ##1 
            (`INSTR == instr_lines[4])[*1:l4_delay] 
            ##1 
            (`INSTR == instr_lines[5] && csp_at_entry_no_memory_overlap)[*1:l5_delay] 
            ##1 
            (`INSTR == instr_lines[6] && csp_at_entry_no_memory_overlap)[*1:l6_delay] 
            ##1 
            (`INSTR == instr_lines[7] && csp_at_entry_no_memory_overlap)[*1:l7_delay] 
            ##1 
            instr_has_changed
            |-> $past(mtdc == csp_at_entry  && mtdc_addr == csp_addr_at_entry)
            && ~overlap(csp, csp_addr, $past(csp_at_entry), $past(csp_addr_at_entry)) 
            && ~overlap($past(csp_at_entry), $past(csp_addr_at_entry), ct2, ct2_addr) 
            && ~overlap($past(csp_at_entry), $past(csp_addr_at_entry), cra, cra_addr)
        );
        endproperty
        push_through: assert property (push_through_prop);
    endmodule

     module helpers;
        //-----------------------------------------------------------
        // Defining some helper properties
        //-----------------------------------------------------------     

        
        property instr_lifecycle_prop;
            (`INSTR_LIFECYCLE |-> ##1 $past(instr_will_progress));
        endproperty
        instr_lifecycle: assert property (instr_lifecycle_prop);

        property mtdc_continuity_prop;
            (`INSTR == instr_lines[1] | `INSTR == instr_lines[2] | `INSTR == instr_lines[3] |
            `INSTR == instr_lines[4] | `INSTR == instr_lines[5] | `INSTR == instr_lines[6] | `INSTR == instr_lines[7]
            |->  mtdc == $past(mtdc) && mtdc_addr == $past(mtdc_addr)
            );
        endproperty
        mtdc_continuity: assert property (mtdc_continuity_prop);




        property instr_validity_prop;
            (##1 `INSTR != $past(`INSTR)
            |-> wbexc_exists
            );
        endproperty
        instr_validity: assert property (instr_validity_prop);

        property no_err_prop;
          (PCCHasASR && csp_assumptions && wbexc_exists && `INSTR == instr_lines[0] && ~wbexc_fetch_err
          |-> ~wbexc_err);
        endproperty
        no_err: assert property (no_err_prop);

        property no_change_while_not_progressing_prop;
            (~instr_will_progress |-> ##1 $stable(`INSTR));
        endproperty
        no_change_while_not_progressing: assert property (no_change_while_not_progressing_prop);

        // property csp_no_change_prop;
        //     (`INSTR_WB(0) |-> $stable(csp) throughout `INSTR_LIFECYCLE);
        // endproperty
        // csp_no_change: assert property (csp_no_change_prop);

        
        // property csp_at_entry_continuity_prop;
        //     (`INSTR != instr_lines[0]
        //     |->  csp_at_entry == $past(csp_at_entry) && csp_addr_at_entry == $past(csp_addr_at_entry)
        //     );
        // endproperty
        // csp_at_entry_continuity: assert property (csp_at_entry_continuity_prop);

        // property ct2_continuity_prop;
        //     (`INSTR == instr_lines[0] | `INSTR == instr_lines[2] | `INSTR == instr_lines[3] |
        //     `INSTR == instr_lines[4] | `INSTR == instr_lines[5] | `INSTR == instr_lines[7]
        //     |=>  ct2 == $past(ct2) && ct2_addr == $past(ct2_addr)
        //     );
        // endproperty
        // ct2_continuity: assert property (ct2_continuity_prop);
    endmodule

    module test;
        // This module is for testing the ADDI instruction
        // It checks that the instruction is executed correctly and that the registers are updated as expected

        // define shortcuts for parts of the ADDI instruction
        logic[5:0] rd =  `INSTR[11:7];
        logic[5:0] rs1 = `INSTR[19:15];
        logic [11:0] imm = `INSTR[31:20];
        logic is_neg = `INSTR[31:31] == 1'b1;

        // define the ADDI instruction property -> compute expected behaviour
        logic [31:0] past_imm;
        always @(posedge clk_i) begin
            if (is_neg) begin
                past_imm <= imm + 32'hFFFFF000; 
            end else begin
                past_imm <= imm;
            end
        end

        // check that ADDI is executed correctly in one cycle
        clock_prop: assert property (
            finishing_executed & ~wbexc_illegal &&
            `IS_ADDI   & rd != 5'd0 
            |-> ##1 regs[$past(rd)] == $past(regs[rs1]) + past_imm
        );

        // Just for fun: check that ADDI is executed correctly in two cycles
        // here, we assume that the destination register stays the same 
        // and the source register of the second cycle is the same as the destination register of the first cycle
        // i.e. we have the effect rd = rs1 + imm1 + imm2
        clock_prop_double: assert property (
            finishing_executed & ~wbexc_illegal &&
            `IS_ADDI & rd != 5'd0 
            ##1 
            finishing_executed & ~wbexc_illegal &&
            `IS_ADDI & rd == $past(rd) && rs1 == $past(rd) 
            |-> ##1 regs[$past(rd)] == $past(regs[rs1], 2) + past_imm + $past(past_imm)
        );

    endmodule

endmodule


