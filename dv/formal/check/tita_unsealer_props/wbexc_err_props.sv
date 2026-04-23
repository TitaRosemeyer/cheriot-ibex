
property no_wbexc_err_1_l00_cgettag_prop; 
	(assumption and (`INSTR_WB(l00_cgettag)) 
	|-> (~wbexc_err | (obj_ptr_safe && us_auth_safe)));
endproperty; 
no_wbexc_err_1_l00_cgettag: assert property (no_wbexc_err_1_l00_cgettag_prop);
    

property no_wbexc_err_2_l04_beqz_prop; 
	(assumption and (`INSTR_WB(l00_cgettag) && instr_will_progress 
        ##1 `INSTR_WB(l04_beqz)) 
	|-> (~wbexc_err | (obj_ptr_safe && us_auth_safe)));
endproperty; 
no_wbexc_err_2_l04_beqz: assert property (no_wbexc_err_2_l04_beqz_prop);
    

property no_wbexc_err_3_l06_cgetbase_prop; 
	(assumption and (`INSTR_WB(l00_cgettag) && instr_will_progress 
        ##1 `INSTR_WB(l04_beqz) && instr_will_progress && ~wbexc_has_branched 
        ##1 `INSTR_WB(l06_cgetbase)) 
	|-> (~wbexc_err | (obj_ptr_safe && us_auth_safe)));
endproperty; 
no_wbexc_err_3_l06_cgetbase: assert property (no_wbexc_err_3_l06_cgetbase_prop);
    

property no_wbexc_err_4_l0a_bne_prop; 
	(assumption and (`INSTR_WB(l00_cgettag) && instr_will_progress 
        ##1 `INSTR_WB(l04_beqz) && instr_will_progress && ~wbexc_has_branched 
        ##1 `INSTR_WB(l06_cgetbase) && instr_will_progress 
        ##1 `INSTR_WB(l0a_bne)) 
	|-> (~wbexc_err | (obj_ptr_safe && us_auth_safe)));
endproperty; 
no_wbexc_err_4_l0a_bne: assert property (no_wbexc_err_4_l0a_bne_prop);
    

property no_wbexc_err_5_l0e_cgetlen_prop; 
	(assumption and (`INSTR_WB(l00_cgettag) && instr_will_progress 
        ##1 `INSTR_WB(l04_beqz) && instr_will_progress && ~wbexc_has_branched 
        ##1 `INSTR_WB(l06_cgetbase) && instr_will_progress 
        ##1 `INSTR_WB(l0a_bne) && instr_will_progress && ~wbexc_has_branched 
        ##1 `INSTR_WB(l0e_cgetlen)) 
	|-> (~wbexc_err | (obj_ptr_safe && us_auth_safe)));
endproperty; 
no_wbexc_err_5_l0e_cgetlen: assert property (no_wbexc_err_5_l0e_cgetlen_prop);
    

property no_wbexc_err_6_l12_beqz_prop; 
	(assumption and (`INSTR_WB(l00_cgettag) && instr_will_progress 
        ##1 `INSTR_WB(l04_beqz) && instr_will_progress && ~wbexc_has_branched 
        ##1 `INSTR_WB(l06_cgetbase) && instr_will_progress 
        ##1 `INSTR_WB(l0a_bne) && instr_will_progress && ~wbexc_has_branched 
        ##1 `INSTR_WB(l0e_cgetlen) && instr_will_progress 
        ##1 `INSTR_WB(l12_beqz)) 
	|-> (~wbexc_err | (obj_ptr_safe && us_auth_safe)));
endproperty; 
no_wbexc_err_6_l12_beqz: assert property (no_wbexc_err_6_l12_beqz_prop);
    

property no_wbexc_err_7_l14_cgetperm_prop; 
	(assumption and (`INSTR_WB(l00_cgettag) && instr_will_progress 
        ##1 `INSTR_WB(l04_beqz) && instr_will_progress && ~wbexc_has_branched 
        ##1 `INSTR_WB(l06_cgetbase) && instr_will_progress 
        ##1 `INSTR_WB(l0a_bne) && instr_will_progress && ~wbexc_has_branched 
        ##1 `INSTR_WB(l0e_cgetlen) && instr_will_progress 
        ##1 `INSTR_WB(l12_beqz) && instr_will_progress && ~wbexc_has_branched 
        ##1 `INSTR_WB(l14_cgetperm)) 
	|-> (~wbexc_err | (obj_ptr_safe && us_auth_safe)));
endproperty; 
no_wbexc_err_7_l14_cgetperm: assert property (no_wbexc_err_7_l14_cgetperm_prop);
    

property no_wbexc_err_8_l18_andi_prop; 
	(assumption and (`INSTR_WB(l00_cgettag) && instr_will_progress 
        ##1 `INSTR_WB(l04_beqz) && instr_will_progress && ~wbexc_has_branched 
        ##1 `INSTR_WB(l06_cgetbase) && instr_will_progress 
        ##1 `INSTR_WB(l0a_bne) && instr_will_progress && ~wbexc_has_branched 
        ##1 `INSTR_WB(l0e_cgetlen) && instr_will_progress 
        ##1 `INSTR_WB(l12_beqz) && instr_will_progress && ~wbexc_has_branched 
        ##1 `INSTR_WB(l14_cgetperm) && instr_will_progress 
        ##1 `INSTR_WB(l18_andi)) 
	|-> (~wbexc_err | (obj_ptr_safe && us_auth_safe)));
endproperty; 
no_wbexc_err_8_l18_andi: assert property (no_wbexc_err_8_l18_andi_prop);
    

property no_wbexc_err_9_l1c_bne_prop; 
	(assumption and (`INSTR_WB(l00_cgettag) && instr_will_progress 
        ##1 `INSTR_WB(l04_beqz) && instr_will_progress && ~wbexc_has_branched 
        ##1 `INSTR_WB(l06_cgetbase) && instr_will_progress 
        ##1 `INSTR_WB(l0a_bne) && instr_will_progress && ~wbexc_has_branched 
        ##1 `INSTR_WB(l0e_cgetlen) && instr_will_progress 
        ##1 `INSTR_WB(l12_beqz) && instr_will_progress && ~wbexc_has_branched 
        ##1 `INSTR_WB(l14_cgetperm) && instr_will_progress 
        ##1 `INSTR_WB(l18_andi) && instr_will_progress 
        ##1 `INSTR_WB(l1c_bne)) 
	|-> (~wbexc_err | (obj_ptr_safe && us_auth_safe)));
endproperty; 
no_wbexc_err_9_l1c_bne: assert property (no_wbexc_err_9_l1c_bne_prop);
    

property no_wbexc_err_10_l1e_cunseal_prop; 
	(assumption and (`INSTR_WB(l00_cgettag) && instr_will_progress 
        ##1 `INSTR_WB(l04_beqz) && instr_will_progress && ~wbexc_has_branched 
        ##1 `INSTR_WB(l06_cgetbase) && instr_will_progress 
        ##1 `INSTR_WB(l0a_bne) && instr_will_progress && ~wbexc_has_branched 
        ##1 `INSTR_WB(l0e_cgetlen) && instr_will_progress 
        ##1 `INSTR_WB(l12_beqz) && instr_will_progress && ~wbexc_has_branched 
        ##1 `INSTR_WB(l14_cgetperm) && instr_will_progress 
        ##1 `INSTR_WB(l18_andi) && instr_will_progress 
        ##1 `INSTR_WB(l1c_bne) && instr_will_progress && ~wbexc_has_branched 
        ##1 `INSTR_WB(l1e_cunseal)) 
	|-> (~wbexc_err | (obj_ptr_safe && us_auth_safe)));
endproperty; 
no_wbexc_err_10_l1e_cunseal: assert property (no_wbexc_err_10_l1e_cunseal_prop);
    

property no_wbexc_err_11_l22_cgettag_prop; 
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
        ##1 `INSTR_WB(l22_cgettag)) 
	|-> (~wbexc_err | (obj_ptr_safe && us_auth_safe)));
endproperty; 
no_wbexc_err_11_l22_cgettag: assert property (no_wbexc_err_11_l22_cgettag_prop);
    

property no_wbexc_err_12_l26_beqz_prop; 
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
        ##1 `INSTR_WB(l26_beqz)) 
	|-> (~wbexc_err | (obj_ptr_safe && us_auth_safe)));
endproperty; 
no_wbexc_err_12_l26_beqz: assert property (no_wbexc_err_12_l26_beqz_prop);
    

property no_wbexc_err_13_l28_clw_prop; 
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
        ##1 `INSTR_WB(l28_clw) && ~instr_will_progress) 
	|-> (~wbexc_err | (obj_ptr_safe && us_auth_safe)));
endproperty; 
no_wbexc_err_13_l28_clw: assert property (no_wbexc_err_13_l28_clw_prop);
    

property no_wbexc_err_14_l2a_bne_prop; 
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
        ##1 `INSTR_WB(l2a_bne)) 
	|-> (~wbexc_err | (obj_ptr_safe && us_auth_safe)));
endproperty; 
no_wbexc_err_14_l2a_bne: assert property (no_wbexc_err_14_l2a_bne_prop);
    

property no_wbexc_err_15_l2e_cgettop_prop; 
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
        ##1 `INSTR_WB(l2e_cgettop)) 
	|-> (~wbexc_err | (obj_ptr_safe && us_auth_safe)));
endproperty; 
no_wbexc_err_15_l2e_cgettop: assert property (no_wbexc_err_15_l2e_cgettop_prop);
    

property no_wbexc_err_16_l32_cinoffset_prop; 
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
        ##1 `INSTR_WB(l32_cinoffset)) 
	|-> (~wbexc_err | (obj_ptr_safe && us_auth_safe)));
endproperty; 
no_wbexc_err_16_l32_cinoffset: assert property (no_wbexc_err_16_l32_cinoffset_prop);
    

property no_wbexc_err_17_l36_sub_prop; 
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
        ##1 `INSTR_WB(l36_sub)) 
	|-> (~wbexc_err | (obj_ptr_safe && us_auth_safe)));
endproperty; 
no_wbexc_err_17_l36_sub: assert property (no_wbexc_err_17_l36_sub_prop);
    

property no_wbexc_err_18_l3a_csetboundsexact_prop; 
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
        ##1 `INSTR_WB(l3a_csetboundsexact)) 
	|-> (~wbexc_err | (obj_ptr_safe && us_auth_safe)));
endproperty; 
no_wbexc_err_18_l3a_csetboundsexact: assert property (no_wbexc_err_18_l3a_csetboundsexact_prop);
    
property no_wbexc_err_prop;
	(no_wbexc_err_1_l00_cgettag_prop and no_wbexc_err_2_l04_beqz_prop and no_wbexc_err_3_l06_cgetbase_prop and no_wbexc_err_4_l0a_bne_prop and no_wbexc_err_5_l0e_cgetlen_prop and no_wbexc_err_6_l12_beqz_prop and no_wbexc_err_7_l14_cgetperm_prop and no_wbexc_err_8_l18_andi_prop and no_wbexc_err_9_l1c_bne_prop and no_wbexc_err_10_l1e_cunseal_prop and no_wbexc_err_11_l22_cgettag_prop and no_wbexc_err_12_l26_beqz_prop and no_wbexc_err_13_l28_clw_prop and no_wbexc_err_14_l2a_bne_prop and no_wbexc_err_15_l2e_cgettop_prop and no_wbexc_err_16_l32_cinoffset_prop and no_wbexc_err_17_l36_sub_prop and no_wbexc_err_18_l3a_csetboundsexact_prop);
endproperty;
no_wbexc_err: assert property (no_wbexc_err_prop);
