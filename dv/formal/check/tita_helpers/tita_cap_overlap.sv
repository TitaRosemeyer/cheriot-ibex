
`ifndef CHERI_GET_BOUND
`define CHERI_GET_BOUND 
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


function automatic logic [32:0] get_top_bound33(reg_cap_t cap, logic [31:0] addr);
    return get_bound(cap.top, cap.top_cor, cap.exp, addr);
endfunction

function automatic logic [31:0] get_base_bound32(reg_cap_t cap, logic [31:0] addr);
    // have to extend base_cor to work with negative sign extension
    return get_bound(cap.base, {2{cap.base_cor}}, cap.exp, addr)[31:0];
endfunction

function automatic bit overlap(reg_cap_t cap1, logic [31:0] addr1, reg_cap_t cap2, logic [31:0] addr2);
    // what about invalid capabilities? 
    // what about permissions?
    logic [32:0] top1 = get_top_bound33(cap1, addr1);
    logic [32:0] top2 = get_top_bound33(cap2, addr2);
    logic [31:0] base1 = get_base_bound32(cap1, addr1);
    logic [31:0] base2 = get_base_bound32(cap2, addr2);
    return ~((top1 < base2) || (top2 < base1));
endfunction
`endif

// Macro to define overlap function with capability registers
// Macro to define overlap function with capability registers and store problem index
`define CAPNOOVERLAPREGS_FN(FNNAME, CONDITION) \
	int FNNAME``_problem_index = -1; \
	function automatic bit FNNAME(reg_cap_t cap, logic [31:0] cap_addr); \
		bit result = 1; \
		FNNAME``_problem_index = -1; \
		for (int i = 0; i < 32; i++) begin \
			if (CONDITION) \
				if(overlap(`RF.rf_cap[i], regs[i], cap, cap_addr)) begin \
					FNNAME``_problem_index = i; \
					return 0; \
				end \
		end \
		return 1; \
	endfunction