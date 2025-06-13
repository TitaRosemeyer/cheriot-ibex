
//----------------------------------------------------------
// Defining a buffer for delayed storage of the csp value
//----------------------------------------------------------

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


// different approach: store at the entry of the first instruction
// problematic if instruction appears multiple times, but should be fine for the current code
reg_cap_t csp_at_entry = NULL_REG_CAP;
logic [31:0] csp_addr_at_entry = 32'h0;
always_latch begin 
    if ($past(instr_will_progress) && `INSTR == instr_lines[0] && wbexc_exists) begin
        csp_at_entry = csp;
        csp_addr_at_entry = csp_addr;
    end
end