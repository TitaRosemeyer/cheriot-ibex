
property no_wbexc_err_1_l00_cgettag_prop; 
	(`INSTR_WB(l00_cgettag) 
	|-> ~wbexc_err);
endproperty; 
no_wbexc_err_1_l00_cgettag: assert property (no_wbexc_err_1_l00_cgettag_prop);
    

property no_wbexc_err_2_l04_beqz_prop; 
	(`INSTR_WB(l00_cgettag) && instr_will_progress 
        ##1 `INSTR_WB(l04_beqz) 
	|-> ~wbexc_err);
endproperty; 
no_wbexc_err_2_l04_beqz: assert property (no_wbexc_err_2_l04_beqz_prop);
    

property no_wbexc_err_3_l06_cgetbase_prop; 
	(`INSTR_WB(l00_cgettag) && instr_will_progress 
        ##1 `INSTR_WB(l04_beqz) && instr_will_progress && ~wbexc_has_branched 
        ##1 `INSTR_WB(l06_cgetbase) 
	|-> ~wbexc_err);
endproperty; 
no_wbexc_err_3_l06_cgetbase: assert property (no_wbexc_err_3_l06_cgetbase_prop);
    

property no_wbexc_err_4_l0a_bne_prop; 
	(`INSTR_WB(l00_cgettag) && instr_will_progress 
        ##1 `INSTR_WB(l04_beqz) && instr_will_progress && ~wbexc_has_branched 
        ##1 `INSTR_WB(l06_cgetbase) && instr_will_progress 
        ##1 `INSTR_WB(l0a_bne) 
	|-> ~wbexc_err);
endproperty; 
no_wbexc_err_4_l0a_bne: assert property (no_wbexc_err_4_l0a_bne_prop);
    

property no_wbexc_err_5_l0e_cgetlen_prop; 
	(`INSTR_WB(l00_cgettag) && instr_will_progress 
        ##1 `INSTR_WB(l04_beqz) && instr_will_progress && ~wbexc_has_branched 
        ##1 `INSTR_WB(l06_cgetbase) && instr_will_progress 
        ##1 `INSTR_WB(l0a_bne) && instr_will_progress && ~wbexc_has_branched 
        ##1 `INSTR_WB(l0e_cgetlen) 
	|-> ~wbexc_err);
endproperty; 
no_wbexc_err_5_l0e_cgetlen: assert property (no_wbexc_err_5_l0e_cgetlen_prop);
    

property no_wbexc_err_6_l12_beqz_prop; 
	(`INSTR_WB(l00_cgettag) && instr_will_progress 
        ##1 `INSTR_WB(l04_beqz) && instr_will_progress && ~wbexc_has_branched 
        ##1 `INSTR_WB(l06_cgetbase) && instr_will_progress 
        ##1 `INSTR_WB(l0a_bne) && instr_will_progress && ~wbexc_has_branched 
        ##1 `INSTR_WB(l0e_cgetlen) && instr_will_progress 
        ##1 `INSTR_WB(l12_beqz) 
	|-> ~wbexc_err);
endproperty; 
no_wbexc_err_6_l12_beqz: assert property (no_wbexc_err_6_l12_beqz_prop);
    

property no_wbexc_err_7_l14_cgetperm_prop; 
	(`INSTR_WB(l00_cgettag) && instr_will_progress 
        ##1 `INSTR_WB(l04_beqz) && instr_will_progress && ~wbexc_has_branched 
        ##1 `INSTR_WB(l06_cgetbase) && instr_will_progress 
        ##1 `INSTR_WB(l0a_bne) && instr_will_progress && ~wbexc_has_branched 
        ##1 `INSTR_WB(l0e_cgetlen) && instr_will_progress 
        ##1 `INSTR_WB(l12_beqz) && instr_will_progress && ~wbexc_has_branched 
        ##1 `INSTR_WB(l14_cgetperm) 
	|-> ~wbexc_err);
endproperty; 
no_wbexc_err_7_l14_cgetperm: assert property (no_wbexc_err_7_l14_cgetperm_prop);
    

property no_wbexc_err_8_l18_andi_prop; 
	(`INSTR_WB(l00_cgettag) && instr_will_progress 
        ##1 `INSTR_WB(l04_beqz) && instr_will_progress && ~wbexc_has_branched 
        ##1 `INSTR_WB(l06_cgetbase) && instr_will_progress 
        ##1 `INSTR_WB(l0a_bne) && instr_will_progress && ~wbexc_has_branched 
        ##1 `INSTR_WB(l0e_cgetlen) && instr_will_progress 
        ##1 `INSTR_WB(l12_beqz) && instr_will_progress && ~wbexc_has_branched 
        ##1 `INSTR_WB(l14_cgetperm) && instr_will_progress 
        ##1 `INSTR_WB(l18_andi) 
	|-> ~wbexc_err);
endproperty; 
no_wbexc_err_8_l18_andi: assert property (no_wbexc_err_8_l18_andi_prop);
    

property no_wbexc_err_9_l1c_bne_prop; 
	(`INSTR_WB(l00_cgettag) && instr_will_progress 
        ##1 `INSTR_WB(l04_beqz) && instr_will_progress && ~wbexc_has_branched 
        ##1 `INSTR_WB(l06_cgetbase) && instr_will_progress 
        ##1 `INSTR_WB(l0a_bne) && instr_will_progress && ~wbexc_has_branched 
        ##1 `INSTR_WB(l0e_cgetlen) && instr_will_progress 
        ##1 `INSTR_WB(l12_beqz) && instr_will_progress && ~wbexc_has_branched 
        ##1 `INSTR_WB(l14_cgetperm) && instr_will_progress 
        ##1 `INSTR_WB(l18_andi) && instr_will_progress 
        ##1 `INSTR_WB(l1c_bne) 
	|-> ~wbexc_err);
endproperty; 
no_wbexc_err_9_l1c_bne: assert property (no_wbexc_err_9_l1c_bne_prop);
    

property no_wbexc_err_10_l1e_cunseal_prop; 
	(`INSTR_WB(l00_cgettag) && instr_will_progress 
        ##1 `INSTR_WB(l04_beqz) && instr_will_progress && ~wbexc_has_branched 
        ##1 `INSTR_WB(l06_cgetbase) && instr_will_progress 
        ##1 `INSTR_WB(l0a_bne) && instr_will_progress && ~wbexc_has_branched 
        ##1 `INSTR_WB(l0e_cgetlen) && instr_will_progress 
        ##1 `INSTR_WB(l12_beqz) && instr_will_progress && ~wbexc_has_branched 
        ##1 `INSTR_WB(l14_cgetperm) && instr_will_progress 
        ##1 `INSTR_WB(l18_andi) && instr_will_progress 
        ##1 `INSTR_WB(l1c_bne) && instr_will_progress && ~wbexc_has_branched 
        ##1 `INSTR_WB(l1e_cunseal) 
	|-> ~wbexc_err);
endproperty; 
no_wbexc_err_10_l1e_cunseal: assert property (no_wbexc_err_10_l1e_cunseal_prop);
    

property no_wbexc_err_11_l22_cgettag_prop; 
	(`INSTR_WB(l00_cgettag) && instr_will_progress 
        ##1 `INSTR_WB(l04_beqz) && instr_will_progress && ~wbexc_has_branched 
        ##1 `INSTR_WB(l06_cgetbase) && instr_will_progress 
        ##1 `INSTR_WB(l0a_bne) && instr_will_progress && ~wbexc_has_branched 
        ##1 `INSTR_WB(l0e_cgetlen) && instr_will_progress 
        ##1 `INSTR_WB(l12_beqz) && instr_will_progress && ~wbexc_has_branched 
        ##1 `INSTR_WB(l14_cgetperm) && instr_will_progress 
        ##1 `INSTR_WB(l18_andi) && instr_will_progress 
        ##1 `INSTR_WB(l1c_bne) && instr_will_progress && ~wbexc_has_branched 
        ##1 `INSTR_WB(l1e_cunseal) && instr_will_progress 
        ##1 `INSTR_WB(l22_cgettag) 
	|-> ~wbexc_err);
endproperty; 
no_wbexc_err_11_l22_cgettag: assert property (no_wbexc_err_11_l22_cgettag_prop);
    

property no_wbexc_err_12_l26_beqz_prop; 
	(`INSTR_WB(l00_cgettag) && instr_will_progress 
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
        ##1 `INSTR_WB(l26_beqz) 
	|-> ~wbexc_err);
endproperty; 
no_wbexc_err_12_l26_beqz: assert property (no_wbexc_err_12_l26_beqz_prop);
    

property no_wbexc_err_13_l28_clw_prop; 
	(`INSTR_WB(l00_cgettag) && instr_will_progress 
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
        ##1 `INSTR_WB(l28_clw) && ~instr_will_progress // load stalls for one cycle 
	|-> ~wbexc_err);
endproperty; 
no_wbexc_err_13_l28_clw: assert property (no_wbexc_err_13_l28_clw_prop);
    

property no_wbexc_err_14_l2a_bne_prop; 
	(`INSTR_WB(l00_cgettag) && instr_will_progress 
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
        ##1 `INSTR_WB(l28_clw) && ~instr_will_progress // load stalls for one cycle
        ##1 instr_will_progress
        ##1 `INSTR_WB(l2a_bne) 
	|-> ~wbexc_err);
endproperty; 
no_wbexc_err_14_l2a_bne: assert property (no_wbexc_err_14_l2a_bne_prop);
    

property no_wbexc_err_15_l2e_cgettop_prop; 
	(`INSTR_WB(l00_cgettag) && instr_will_progress 
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
        ##1 `INSTR_WB(l28_clw) && ~instr_will_progress // load stalls for one cycle
        ##1 instr_will_progress
        ##1 `INSTR_WB(l2a_bne) && instr_will_progress && ~wbexc_has_branched
        ##1 `INSTR_WB(l2e_cgettop) 
	|-> ~wbexc_err);
endproperty; 
no_wbexc_err_15_l2e_cgettop: assert property (no_wbexc_err_15_l2e_cgettop_prop);
    

property no_wbexc_err_16_l32_cinoffset_prop; 
	(`INSTR_WB(l00_cgettag) && instr_will_progress 
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
        ##1 `INSTR_WB(l28_clw) && ~instr_will_progress // load stalls for one cycle
        ##1 instr_will_progress
        ##1 `INSTR_WB(l2a_bne) && instr_will_progress && ~wbexc_has_branched
        ##1 `INSTR_WB(l2e_cgettop) && instr_will_progress
        ##1 `INSTR_WB(l32_cinoffset) 
	|-> ~wbexc_err);
endproperty; 
no_wbexc_err_16_l32_cinoffset: assert property (no_wbexc_err_16_l32_cinoffset_prop);
    

property no_wbexc_err_17_l36_sub_prop; 
	(`INSTR_WB(l00_cgettag) && instr_will_progress 
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
        ##1 `INSTR_WB(l28_clw) && ~instr_will_progress // load stalls for one cycle
        ##1 instr_will_progress
        ##1 `INSTR_WB(l2a_bne) && instr_will_progress && ~wbexc_has_branched
        ##1 `INSTR_WB(l2e_cgettop) && instr_will_progress
        ##1 `INSTR_WB(l32_cinoffset) && instr_will_progress
        ##1 `INSTR_WB(l36_sub) 
	|-> ~wbexc_err);
endproperty; 
no_wbexc_err_17_l36_sub: assert property (no_wbexc_err_17_l36_sub_prop);
    

property no_wbexc_err_18_l3a_csetboundsexact_prop; 
	(`INSTR_WB(l00_cgettag) && instr_will_progress 
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
        ##1 `INSTR_WB(l28_clw) && ~instr_will_progress // load stalls for one cycle
        ##1 instr_will_progress
        ##1 `INSTR_WB(l2a_bne) && instr_will_progress && ~wbexc_has_branched
        ##1 `INSTR_WB(l2e_cgettop) && instr_will_progress
        ##1 `INSTR_WB(l32_cinoffset) && instr_will_progress
        ##1 `INSTR_WB(l36_sub) && instr_will_progress
        ##1 `INSTR_WB(l3a_csetboundsexact) 
	|-> ~wbexc_err);
endproperty; 
no_wbexc_err_18_l3a_csetboundsexact: assert property (no_wbexc_err_18_l3a_csetboundsexact_prop);
    
