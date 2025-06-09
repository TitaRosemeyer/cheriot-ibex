

`include "tita_helpers/tita_registers.sv"
`include "tita_helpers/tita_cap_overlap.sv"

// Macro to create a buffer for delayed storage
// stores variable VARNAME of type VARTYPE in buffer BUFNAME when STORE_SIG is high
// BUFNAME[i] contains the value of VARNAME at the ith-last time that
// STORE_SIG was high (i.e. i = 0 contains the value from the last (or current) time
// the signal was high) 
// !!! The buffer is always 1 cycle late !!!
`define MAKE_DELAY_BUFFER(BUFNAME, VARNAME, VARTYPE, STORE_SIG, DELAY) \
    VARTYPE BUFNAME [DELAY:0]; \
    always_ff @(posedge clk_i) begin \
        if (STORE_SIG) begin \
            for (int i = 1; i <= DELAY ; i++ ) begin \
                BUFNAME[i] <= BUFNAME[i-1]; \
            end \
            BUFNAME[0] <= VARNAME; \
        end \
    end
parameter CSP_AT_ENTRY_DELAY = 7;
logic instr_has_changed = $past(instr_will_progress);
`MAKE_DELAY_BUFFER(csp_buffer, csp, reg_cap_t, instr_has_changed, CSP_AT_ENTRY_DELAY);
`MAKE_DELAY_BUFFER(csp_addr_buffer, csp_addr, logic[31:0], instr_has_changed, CSP_AT_ENTRY_DELAY);




// testing buffer functionality with test variable:
int test_var = 0;
always @(posedge clk_i ) begin
    test_var <= (test_var+1) % 50;
end
`MAKE_DELAY_BUFFER(test_buffer, test_var, int, instr_has_changed, CSP_AT_ENTRY_DELAY);



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


reg_cap_t csp_at_entry = NULL_REG_CAP;
logic [31:0] csp_addr_at_entry = 32'h0;
always_latch begin 
    if (`INSTR != $past(`INSTR) && `INSTR == instr_lines[0]) begin
        csp_at_entry = csp;
        csp_addr_at_entry = csp_addr;
    end
end


module tita;
    logic [32:0] csp_top = get_top_bound33(csp, csp_addr);
    logic [31:0] csp_base = get_base_bound32(csp, csp_addr);
    BoundsSanityCheck: assert property (csp.valid && csp.exp != 5'd24 |-> csp_top >= csp_base); 
    BigCapBounds: assert property (csp.valid && csp.exp == 5'd24 |-> csp_top >= csp_base);
    OverlapSanityCheck: assert property (csp_top >= csp_base |-> overlap(csp,csp_addr, csp, csp_addr));

    module instructions;

        // Defining overlap functions
        `CAPNOOVERLAPREGS_FN(no_overlap_all_fn, 1)
        `CAPNOOVERLAPREGS_FN(no_overlap_except2_fn, i != 2)

        // Example calls:
        logic csp_no_overlap_all = no_overlap_all_fn(csp, csp_addr);
        logic csp_no_overlap_except2 = no_overlap_except2_fn(csp, csp_addr);

        // CapNoOverlapRegsFnAll: cover property (csp_top >= csp_base && csp_no_overlap_all);
        // CapNoOverlapRegsFnExcept2: cover property (csp_top >= csp_base && csp_no_overlap_except2);

        
        `define CPU_WB_PATH  ibex_top_i.u_ibex_core.wb_stage_i
        reg_cap_t lsu_cap_i = `CPU_WB_PATH.rf_wcap_lsu_i;
        logic [31:0] lsu_addr_i = `CPU_WB_PATH.rf_wdata_lsu_i;
        

        logic csp_no_memory_overlap = ~overlap(csp, csp_addr, lsu_cap_i , lsu_addr_i);
        // Automated generation of csp_no_memory_overlap_N signals using a generate-for loop
        for (genvar i = 1; i <= CSP_AT_ENTRY_DELAY; i++) begin : gen_csp_buffer_no_memory_overlap
            logic csp_buffer_no_memory_overlap_i = ~overlap(csp_buffer[i], csp_addr_buffer[i], lsu_cap_i, lsu_addr_i);
        end
        logic csp_at_entry_no_memory_overlap = ~overlap(csp_at_entry, csp_addr_at_entry, lsu_cap_i, lsu_addr_i);


        logic PCCHasASR = (pcc.cperms[4:2] == 3'b011);
        property cspecialw_test;
            (PCCHasASR &&
            `INSTR == 32'h03d1005b &&
            finishing_executed &&
            no_overlap_except2_fn(csp, csp_addr)
            |->  mtdc == csp &&
            mtdc_addr == regs[2] 
            ##1 
            no_overlap_except2_fn($past(csp), $past(csp_addr))
            );
        endproperty


         
        parameter l0_delay = 2;
        parameter l1_delay = 1;
        parameter l2_delay = 2;
        parameter l3_delay = 3;
        parameter l4_delay = 2;
        parameter l5_delay = 2;
        parameter l6_delay = 2;
        parameter l7_delay = 1;

        // Trying different versions on just the first two lines
        no_overlap_line_1: assert property (
            `INSTR == instr_lines[0] && csp_no_overlap_except2 
            ##1 
            (`INSTR == instr_lines[1] && csp_no_memory_overlap )
            ##1
            instr_has_changed
            |->  no_overlap_except2_fn(csp_buffer[1], csp_addr_buffer[1])
        ); 
        no_overlap_line_1_concrete: assert property (
            `INSTR == instr_lines[0] && csp_no_overlap_except2 
            ##1 
            (`INSTR == instr_lines[1] && csp_at_entry_no_memory_overlap )
            ##1
            instr_has_changed
            |->  no_overlap_except2_fn(csp_at_entry, csp_addr_at_entry)
        ); 

        no_overlap_line_1_old: assert property (
            `INSTR == instr_lines[0] && csp_no_overlap_except2 
            ##1 
            (`INSTR == instr_lines[1] && csp_no_memory_overlap )
            ##1
            instr_has_changed
            |->  csp_no_overlap_except2
        ); 

        // trying on the whole code block
        push_through_concrete_delay: assert property(
            `INSTR == instr_lines[0] && csp_no_overlap_except2
            ##1 
            (`INSTR == instr_lines[1] && csp_no_memory_overlap)[*1]
            ##1
            (`INSTR == instr_lines[2] && csp_no_memory_overlap)[*2]
            ##1
            (`INSTR == instr_lines[3] && csp_no_memory_overlap)[*3]
            ##1 
            (`INSTR == instr_lines[4] && csp_no_memory_overlap)[*2]
            ##1 
            (`INSTR == instr_lines[5] && csp_no_memory_overlap)[*2]
            ##1 
            (`INSTR == instr_lines[6] && csp_no_memory_overlap)[*2]
            ##1 
            (`INSTR == instr_lines[7] && csp_no_memory_overlap)[*1]
            ##1 
            instr_has_changed
            |-> no_overlap_all_fn($past(csp, 14), $past(csp_addr, 14))
        );
        push_through: assert property(
            `INSTR == instr_lines[0] && csp_no_overlap_except2
            ##1 
            (`INSTR == instr_lines[1] && csp_no_memory_overlap)[*1:5]
            ##1
            (`INSTR == instr_lines[2] && csp_no_memory_overlap)[*1:5]
            ##1
            (`INSTR == instr_lines[3] && csp_no_memory_overlap)[*1:5]
            ##1 
            (`INSTR == instr_lines[4] && csp_no_memory_overlap)[*1:5]
            ##1 
            (`INSTR == instr_lines[5] && csp_no_memory_overlap)[*1:5]
            ##1 
            (`INSTR == instr_lines[6] && csp_no_memory_overlap)[*1:5]
            ##1 
            (`INSTR == instr_lines[7] && csp_no_memory_overlap)[*1:5]
            ##1 
            instr_has_changed
            |-> no_overlap_all_fn(csp_buffer[7], csp_addr_buffer[7])
        );

        
        
    endmodule

    module test;
        logic[5:0] rd =  `INSTR[11:7];
        logic[5:0] rs1 = `INSTR[19:15];
        logic [11:0] imm = `INSTR[31:20];
        logic is_neg = `INSTR[31:31] == 1'b1;

        logic [31:0] past_imm;
        always @(posedge clk_i) begin
            if (is_neg) begin
                past_imm <= imm + 32'hFFFFF000; 
            end else begin
                past_imm <= imm;
            end
        end

        clock_prop: assert property (
            finishing_executed & ~wbexc_illegal &&
            `IS_ADDI   & rd != 5'd0 
            |-> ##1 regs[$past(rd)] == $past(regs[rs1]) + past_imm
        );

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


