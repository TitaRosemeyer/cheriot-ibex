/*
This file contains functions to check for overlap between capabilities.

It defines functions to calculate the decompressed bounds of compressed capabilities,
and to check if two capabilities overlap based on their bounds and the addresses they are associated with.

The bounds check is taken from VeriCHERI, with a small fix when computing the base bound.

It also defines a macro to create an overlap function that checks against all capabilities in the register file,
and stores the index of the first overlapping capability if any.
*/


// gets the 33-bit top bound of a compressed capability.
function automatic logic [32:0] get_top_bound33(reg_cap_t cap, logic [31:0] addr);
    return get_bound33(cap.top, cap.top_cor, cap.exp, addr);
endfunction

// gets the 32-bit base bound of a compressed capability.
function automatic logic [31:0] get_base_bound32(reg_cap_t cap, logic [31:0] addr);
    // have to extend base_cor to work with negative sign extension
    return get_bound33(cap.base, {2{cap.base_cor}}, cap.exp, addr)[31:0];
endfunction

// checks if two capabilities overlap based on their bounds and addresses.
// Returns 1 if they overlap, 0 otherwise.
function automatic bit overlap(reg_cap_t cap1, logic [31:0] addr1, reg_cap_t cap2, logic [31:0] addr2);

	logic [32:0] top1 = get_bound33(cap1.top, cap1.top_cor, cap1.exp, addr1);
	logic [32:0] top2 = get_bound33(cap2.top, cap2.top_cor, cap2.exp, addr2);
	logic [32:0] base1 = get_bound33(cap1.base, {2{cap1.base_cor}}, cap1.exp, addr1);
	logic [32:0] base2 = get_bound33(cap2.base, {2{cap2.base_cor}}, cap2.exp, addr2);

	// check if the bounds overlap
    return ~((top1 < base2) || (top2 < base1));
endfunction

function automatic bit has_stricter_bounds(reg_cap_t cap1, logic [31:0] addr1, reg_cap_t cap2, logic [31:0] addr2);
	// Check if cap1 has at least as strict bounds as cap2
	logic [32:0] top1 = get_bound33(cap1.top, cap1.top_cor, cap1.exp, addr1);
	logic [32:0] top2 = get_bound33(cap2.top, cap2.top_cor, cap2.exp, addr2);
	logic [32:0] base1 = get_bound33(cap1.base, {2{cap1.base_cor}}, cap1.exp, addr1);
	logic [32:0] base2 = get_bound33(cap2.base, {2{cap2.base_cor}}, cap2.exp, addr2);

	// If cap1's top is less than or equal to cap2's top and cap1's base is greater than or equal to cap2's base
	return (top1 <= top2) && (base1 >= base2);
endfunction


function automatic bit has_fewer_perms(reg_cap_t cap1, reg_cap_t cap2);
	// Check if cap1 has at least as strict permissions as cap2
	logic [11:0] perms1 = expand_perms(cap1.cperms);
	logic [11:0] perms2 = expand_perms(cap2.cperms);

	// There are 12 permissions possible in a capability,
	// 11 10  9  8  7  6  5  4  3  2  1  0
	// U0 SE US EX SR MC LD SL LM SD LG GL
	// They are compressed in the 6 bits of the perm field.
	
	// If cap1 has a permission then cap2 must also have it
	return (perms1 & perms2) == perms1;
endfunction

function automatic bit derived_from(reg_cap_t cap1, logic [31:0] addr1, reg_cap_t cap2, logic [31:0] addr2);
	// Check if cap1 could be derived from cap2
	logic result = 1;
	
	logic both_valid = (cap1.valid && cap2.valid);
	// logic both_unsealed = (cap1.otype == 3'b000 && cap2.otype == 3'b000);
	logic fewer_perms = has_fewer_perms(cap1, cap2);
	logic stricter_bounds = has_stricter_bounds(cap1, addr1, cap2, addr2);

	return both_valid && stricter_bounds && fewer_perms;
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