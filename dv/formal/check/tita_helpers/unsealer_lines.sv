logic [31:0] l00_cgettag = 32'hfe4506db;    // 0:           ct.cgettag	a3, ca0
logic [31:0] l04_beqz = 32'h00068063;       // 4:  c281     beqz	a3, 0x4 <.Ltoken_unseal_internal+0x4> -> Lexit_failure

logic [31:0] l06_cgetbase = 32'hfe2506db;   // 6:           ct.cgetbase	a3, ca0 
logic [31:0] l0a_bne = 32'h00d51063;        // 10:          bne	a0, a3, 0xa <.Ltoken_unseal_internal+0xa> -> Lexit_failure

logic [31:0] l0e_cgetlen = 32'hfe3506db;    // 14:          ct.cgetlen	a3, ca0
logic [31:0] l12_beqz = 32'h00068063;       // 18: c281     beqz	a3, 0x12 <.Ltoken_unseal_internal+0x12> -> Lexit_failure

logic [31:0] l14_cgetperm = 32'hfe0506db;   // 1c:          ct.cgetperm	a3, ca0
logic [31:0] l18_andi = 32'h2006f693;       // 20:          andi	a3, a3, 0x200
logic [31:0] l1c_bne = 32'h00d51063;        // 24:          bne	a0, a3, 0x1c <.Ltoken_unseal_internal+0x1c> -> Lexit_failure

logic [31:0] l1e_cunseal = 32'h18c5865b;    // 1e:          ct.cunseal	ca2, ca1, ca2
logic [31:0] l22_cgettag = 32'hfe4606db;    // 22:          ct.cgettag	a3, ca2
logic [31:0] l26_beqz = 32'h00068063;       // 26: c281     beqz	a3, 0x26 <.Ltoken_unseal_internal+0x26> -> Lexit_failure

logic [31:0] l28_clw = 32'h00062683;        // 28: 4214     ct.clw	a3, 0x0(ca2)
logic [31:0] l2a_bne = 32'h00d51063;        // 2a:          bne	    a0, a3, 0x2a <.Ltoken_unseal_internal+0x2a> -> Lexit_failure

logic [31:0] l2e_cgettop = 32'hff8606db;    // 2e:          ct.cgettop	a3, ca2
logic [31:0] l32_cinoffset = 32'h0086155b;  // 32:          ct.cincoffset	ca0, ca2, 0x8
logic [31:0] l36_sub = 32'h40a68633;        // 36:          sub	    a2, a3, a0
logic [31:0] l3a_csetboundsexact = 32'h12c5055b;    // 3a:          ct.csetboundsexact	ca0, ca0, a2
logic [31:0] l3e_cret = 32'h00008067;   // 3e: 8082     ct.cret

// --------- Failure path ---------
logic [31:0] l40_li_a2 = 32'h00000613;  // 40: 4601     li	a2, 0x0
logic [31:0] l42_li_a0 = 32'h00000513;  // 42: 4501     li	a0, 0x0
logic [31:0] l44_cret = 32'h00008067;   // 44: 8082     ct.cret

// check if the encoded instructions are decoded correctly
// check_decode_l26_beqz: assert property (instruction_decoding_correctness(16'hc281, l26_beqz));
// check_decode_l28_clw: assert property (instruction_decoding_correctness(16'h4214, l28_clw));
// check_decode_l40_li_a2: assert property (instruction_decoding_correctness(16'h4601, l40_li_a2));
// check_decode_l42_li_a0: assert property (instruction_decoding_correctness(16'h4501, l42_li_a0));
// check_decode_l44_cret: assert property (instruction_decoding_correctness(16'h8082, l44_cret));