
sequence branch_1_l00_cgettag;
	(assumption and (`INSTR_WB(l00_cgettag) && instr_will_progress 
        ##1 `INSTR_WB(l04_beqz) && wbexc_has_branched 
	##1 ~wbexc_exists 
	##1 failure_sequence));
endsequence;
cover_branch_1_l00_cgettag: cover sequence (branch_1_l00_cgettag);


sequence branch_2_l06_cgetbase;
	(assumption and (`INSTR_WB(l00_cgettag) && instr_will_progress 
        ##1 `INSTR_WB(l04_beqz) && instr_will_progress && ~wbexc_has_branched 
        ##1 `INSTR_WB(l06_cgetbase) && instr_will_progress 
        ##1 `INSTR_WB(l0a_bne) && wbexc_has_branched 
	##1 ~wbexc_exists 
	##1 failure_sequence));
endsequence;
cover_branch_2_l06_cgetbase: cover sequence (branch_2_l06_cgetbase);


sequence branch_3_l0e_cgetlen;
	(assumption and (`INSTR_WB(l00_cgettag) && instr_will_progress 
        ##1 `INSTR_WB(l04_beqz) && instr_will_progress && ~wbexc_has_branched 
        ##1 `INSTR_WB(l06_cgetbase) && instr_will_progress 
        ##1 `INSTR_WB(l0a_bne) && instr_will_progress && ~wbexc_has_branched 
        ##1 `INSTR_WB(l0e_cgetlen) && instr_will_progress 
        ##1 `INSTR_WB(l12_beqz) && wbexc_has_branched 
	##1 ~wbexc_exists 
	##1 failure_sequence));
endsequence;
cover_branch_3_l0e_cgetlen: cover sequence (branch_3_l0e_cgetlen);


sequence branch_4_l14_cgetperm;
	(assumption and (`INSTR_WB(l00_cgettag) && instr_will_progress 
        ##1 `INSTR_WB(l04_beqz) && instr_will_progress && ~wbexc_has_branched 
        ##1 `INSTR_WB(l06_cgetbase) && instr_will_progress 
        ##1 `INSTR_WB(l0a_bne) && instr_will_progress && ~wbexc_has_branched 
        ##1 `INSTR_WB(l0e_cgetlen) && instr_will_progress 
        ##1 `INSTR_WB(l12_beqz) && instr_will_progress && ~wbexc_has_branched 
        ##1 `INSTR_WB(l14_cgetperm) && instr_will_progress 
        ##1 `INSTR_WB(l18_andi) && instr_will_progress 
        ##1 `INSTR_WB(l1c_bne) && wbexc_has_branched 
	##1 ~wbexc_exists 
	##1 failure_sequence));
endsequence;
cover_branch_4_l14_cgetperm: cover sequence (branch_4_l14_cgetperm);


sequence branch_5_l1e_cunseal;
	(assumption and (`INSTR_WB(l00_cgettag) && instr_will_progress 
        ##1 `INSTR_WB(l04_beqz) && instr_will_progress && ~wbexc_has_branched 
        ##1 `INSTR_WB(l06_cgetbase) && instr_will_progress 
        ##1 `INSTR_WB(l0a_bne) && instr_will_progress && ~wbexc_has_branched 
        ##1 `INSTR_WB(l0e_cgetlen) && instr_will_progress 
        ##1 `INSTR_WB(l12_beqz) && instr_will_progress && ~wbexc_has_branched 
        ##1 `INSTR_WB(l14_cgetperm) && instr_will_progress 
        ##1 `INSTR_WB(l18_andi) && instr_will_progress 
        ##1 `INSTR_WB(l1c_bne) && instr_will_progress && ~wbexc_has_branched 
        ##1 `INSTR_WB(l1e_cunseal) && instr_will_progress 
        ##1 `INSTR_WB(l22_cgettag) && instr_will_progress 
        ##1 `INSTR_WB(l26_beqz) && wbexc_has_branched 
	##1 ~wbexc_exists 
	##1 failure_sequence));
endsequence;
cover_branch_5_l1e_cunseal: cover sequence (branch_5_l1e_cunseal);


sequence branch_6_l28_clw;
	(assumption and (`INSTR_WB(l00_cgettag) && instr_will_progress 
        ##1 `INSTR_WB(l04_beqz) && instr_will_progress && ~wbexc_has_branched 
        ##1 `INSTR_WB(l06_cgetbase) && instr_will_progress 
        ##1 `INSTR_WB(l0a_bne) && instr_will_progress && ~wbexc_has_branched 
        ##1 `INSTR_WB(l0e_cgetlen) && instr_will_progress 
        ##1 `INSTR_WB(l12_beqz) && instr_will_progress && ~wbexc_has_branched 
        ##1 `INSTR_WB(l14_cgetperm) && instr_will_progress 
        ##1 `INSTR_WB(l18_andi) && instr_will_progress 
        ##1 `INSTR_WB(l1c_bne) && instr_will_progress && ~wbexc_has_branched 
        ##1 `INSTR_WB(l1e_cunseal) && instr_will_progress 
        ##1 `INSTR_WB(l22_cgettag) && instr_will_progress 
        ##1 `INSTR_WB(l26_beqz) && instr_will_progress && ~wbexc_has_branched 
        ##1 `INSTR_WB(l28_clw) && ~instr_will_progress 
        ##1 instr_will_progress
        ##1 `INSTR_WB(l2a_bne) && wbexc_has_branched 
	##1 ~wbexc_exists 
	##1 failure_sequence));
endsequence;
cover_branch_6_l28_clw: cover sequence (branch_6_l28_clw);


sequence branch_7_success;
	(assumption and (`INSTR_WB(l00_cgettag) && instr_will_progress 
        ##1 `INSTR_WB(l04_beqz) && instr_will_progress && ~wbexc_has_branched 
        ##1 `INSTR_WB(l06_cgetbase) && instr_will_progress 
        ##1 `INSTR_WB(l0a_bne) && instr_will_progress && ~wbexc_has_branched 
        ##1 `INSTR_WB(l0e_cgetlen) && instr_will_progress 
        ##1 `INSTR_WB(l12_beqz) && instr_will_progress && ~wbexc_has_branched 
        ##1 `INSTR_WB(l14_cgetperm) && instr_will_progress 
        ##1 `INSTR_WB(l18_andi) && instr_will_progress 
        ##1 `INSTR_WB(l1c_bne) && instr_will_progress && ~wbexc_has_branched 
        ##1 `INSTR_WB(l1e_cunseal) && instr_will_progress 
        ##1 `INSTR_WB(l22_cgettag) && instr_will_progress 
        ##1 `INSTR_WB(l26_beqz) && instr_will_progress && ~wbexc_has_branched 
        ##1 `INSTR_WB(l28_clw) && ~instr_will_progress 
        ##1 instr_will_progress
        ##1 `INSTR_WB(l2a_bne) && instr_will_progress && ~wbexc_has_branched
        ##1 `INSTR_WB(l2e_cgettop) && instr_will_progress
        ##1 `INSTR_WB(l32_cinoffset) && instr_will_progress
        ##1 `INSTR_WB(l36_sub) && instr_will_progress
        ##1 `INSTR_WB(l3a_csetboundsexact) && instr_will_progress
        ##1 `INSTR_WB(l3e_cret))
        );
endsequence;
cover_branch_7_success: cover sequence (branch_7_success);

