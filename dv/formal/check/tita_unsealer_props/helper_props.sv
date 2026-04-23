
property no_wbexc_err_l40_li_a2_prop;
    (`INSTR_WB(l40_li_a2) 
    |-> ~wbexc_err
    );
endproperty
no_wbexc_err_l40_li_a2: assert property (no_wbexc_err_l40_li_a2_prop);

property no_wbexc_err_l42_li_a0_prop;
    (`INSTR_WB(l42_li_a0) 
    |-> ~wbexc_err
    );
endproperty
no_wbexc_err_l42_li_a0: assert property (no_wbexc_err_l42_li_a0_prop);


property check_ca0_ok_prop;
(success_sequence
|-> ca0_ok
);
endproperty;
check_ca0_ok: assert property (check_ca0_ok_prop);

property check_ca1_ok_prop;
( success_sequence
|-> ca1_ok
);
endproperty;
check_ca1_ok: assert property (check_ca1_ok_prop);





property check_instr_will_progress;
    (instr_will_progress && wbexc_exists
    |-> ~wbexc_err);
endproperty
check_instr_will_progress_assert: assert property (check_instr_will_progress);

property check_failure_ca0_ok_prop;
(failure_sequence
|-> ca0_ok
);
endproperty;
check_failure_ca0_ok: assert property (check_failure_ca0_ok_prop);

property check_ca2_steady_until_l1e_cunseal_prop;
    (`INSTR_WB(l00_cgettag) && instr_will_progress 
    ##1 `INSTR_WB(l04_beqz) && instr_will_progress && ~wbexc_has_branched 
    ##1 `INSTR_WB(l06_cgetbase) && instr_will_progress 
    ##1 `INSTR_WB(l0a_bne) && instr_will_progress && ~wbexc_has_branched 
    ##1 `INSTR_WB(l0e_cgetlen) && instr_will_progress 
    ##1 `INSTR_WB(l12_beqz) && instr_will_progress && ~wbexc_has_branched 
    ##1 `INSTR_WB(l14_cgetperm) && instr_will_progress 
    ##1 `INSTR_WB(l18_andi) && instr_will_progress 
    ##1 `INSTR_WB(l1c_bne) && ~wbexc_has_branched
    |-> ~ca2.valid | (ca2 == ca2_at_entry && a2 == a2_at_entry)
    );
endproperty
check_ca2_steady_until_l1e_cunseal: assert property (check_ca2_steady_until_l1e_cunseal_prop);