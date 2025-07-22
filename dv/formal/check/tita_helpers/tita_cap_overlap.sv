/*
This file contains functions to check for overlap between capabilities.

It defines functions to calculate the decompressed bounds of compressed capabilities,
and to check if two capabilities overlap based on their bounds and the addresses they are associated with.

The bounds check is taken from VeriCHERI, with a small fix when computing the base bound.

It also defines a macro to create an overlap function that checks against all capabilities in the register file,
and stores the index of the first overlapping capability if any.
*/


// get_bound function taken from VeriCHERI, computes the bound of a capability bases on its top or base bits, 
// the correction bits (cor), the exponent (exp), and the address (addr).
// returns a 33-bit value, which is needed for the top bound, and can be reduced to 32 bits for the base bound.
function automatic logic[32:0] get_bound(logic [8:0] top, logic [1:0] cor, logic [4:0] exp,logic [31:0] addr);
	logic [32:0] t1, t2, mask, cor_val;
	if (cor[1])
		cor_val = {33{cor[1]}};
	else
		cor_val = {32'h0, (~cor[1]) & cor[0]};
	cor_val = (cor_val << exp) << 9;
	mask    = (33'h1_ffff_ffff << exp) << 9;
	t1 = ({1'b0, addr} & mask) + cor_val;
	t2 = {24'h0, top};
	t1 = t1 | (t2 << exp);
	return t1;
endfunction

// gets the 33-bit top bound of a compressed capability.
function automatic logic [32:0] get_top_bound33(reg_cap_t cap, logic [31:0] addr);
    return get_bound(cap.top, cap.top_cor, cap.exp, addr);
endfunction

// gets the 32-bit base bound of a compressed capability.
function automatic logic [31:0] get_base_bound32(reg_cap_t cap, logic [31:0] addr);
    // have to extend base_cor to work with negative sign extension
    return get_bound(cap.base, {2{cap.base_cor}}, cap.exp, addr)[31:0];
endfunction

// checks if two capabilities overlap based on their bounds and addresses.
// Returns 1 if they overlap, 0 otherwise.
function automatic bit overlap(reg_cap_t cap1, logic [31:0] addr1, reg_cap_t cap2, logic [31:0] addr2);
    // what about invalid capabilities? 
    // what about permissions?
    logic [32:0] top1 = get_top_bound33(cap1, addr1);
    logic [32:0] top2 = get_top_bound33(cap2, addr2);
    logic [31:0] base1 = get_base_bound32(cap1, addr1);
    logic [31:0] base2 = get_base_bound32(cap2, addr2);
    return ~((top1 < base2) || (top2 < base1));
endfunction


// Given a comparison function CHECK_FN between two capabilities, 
// this macro defines a function that, gets a capability. 
// It returns true if there is no successful comparison with any of the capabilities in the register file.
// If there is a successful comparison, it returns false and stores the index of the first overlapping
// capability in the variable FNNAME``_problem_index.
// The CONDITION parameter is used to filter which registers are checked.
`define NOT_IN_REGS_FN(FNNAME, CONDITION, CHECK_FN) \
	int FNNAME``_problem_index = -1; \
	function automatic bit FNNAME(reg_cap_t cap, logic [31:0] addr); \
		bit result = 1; \
		for (int i = 0; i < 32; i++) begin \
			if (CONDITION) begin \
				if(CHECK_FN(`RF.rf_cap[i], regs[i], cap, addr)) begin \
					FNNAME``_problem_index = i; \
					// add a debug message \
					$display("Problem found in register %0d", i); \
					return 0; \
				end \
				end \
		end \
		return result; \
	endfunction


`define CAP_NO_OVERLAP_REGS_FN(FNNAME, CONDITION) \
	`NOT_IN_REGS_FN(FNNAME, CONDITION, overlap) 