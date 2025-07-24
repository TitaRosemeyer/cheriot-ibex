
/*
   * Register allocation:
   *
   *  - ca0 holds the user's sealing key, and is replaced with the unsealed
   *    value or NULL
   *
   *  - ca1 holds the user's sealed object pointer
   *
   *  - ca2 holds the unsealing authority and is clobbered on failure
   *    explicitly and on success with a scalar (the sealed payload's length)
   *
   *  - a3 is used within each local computation and never holds secrets
*/

/* 
    * sensitive information:
    * - ca1: sealed object pointer (and derived capabilities)
    * - ca2: unsealing authority (and derived capabilities )

    * no sensitive information may be leaked anywhere, except:
    * - in ca0: unsealed pointer with CORRECT BOUNDS
    * - in ca1: sealed object pointer (equal to input argument)
    *
*/
module unsealer_props;
    `include "tita_helpers/unsealer_lines.sv"

    // take a snapshot of the object pointer at the entrypoint (l00_cgettag)
    `MAKE_VAR_AT_ENTRY(ca1, reg_cap_t, l00_cgettag);
    `MAKE_VAR_AT_ENTRY(a1, logic [31:0], l00_cgettag);
    // rename for clarity 
    reg_cap_t obj_ptr = ca1_at_entry; 
    logic [31:0] obj_ptr_addr = a1_at_entry;

    // take a snapshot of the unsealing authority at the entrypoint (l00_cgettag)
    `MAKE_VAR_AT_ENTRY(ca2, reg_cap_t, l00_cgettag);
    `MAKE_VAR_AT_ENTRY(a2, logic [31:0], l00_cgettag);
    // rename for clarity
    reg_cap_t us_auth = ca2_at_entry;
    logic [31:0] us_auth_addr = a2_at_entry;
    
    `CAP_NO_OVERLAP_REGS_FN(no_overlap_all_fn, 1)
    `CAP_NO_OVERLAP_REGS_FN(no_overlap_except_ca0_ca1_ca2_fn, i!= 10 && i!= 11 && i!= 12)

    `NOT_IN_REGS_FN(no_derivatives_all_fn, 1, derived_from);
    `NOT_IN_REGS_FN(no_derivatives_except_ca0_ca1_ca2_fn, i!=10 && i!=11 && i!=12, derived_from);
    `NOT_IN_REGS_FN(no_derivatives_except_ca0_ca1_fn, i!=10 && i!=11, derived_from);

    reg_cap_t test_cap;
    logic [31:0] test_addr;
    sanity_check_derivative: assert property ((test_cap.valid && (test_cap.otype == 3'b000)) ->derived_from(test_cap, test_addr, test_cap, test_addr));
    
    // for debugging
    int ca0_top = int'(get_top_bound33(ca0, a0));
    int ca0_base = int'(get_base_bound32(ca0, a0));
    int ca1_top = int'(get_top_bound33(ca1, a1));
    int ca1_base = int'(get_base_bound32(ca1, a1));
    int ca2_top = int'(get_top_bound33(ca2, a2));
    int ca2_base = int'(get_base_bound32(ca2, a2));



    // define the main success and failure sequences
    sequence success_sequence; 
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
        ##1 `INSTR_WB(l3a_csetboundsexact) && instr_will_progress
        ##1 `INSTR_WB(l3e_cret)
        );
    endsequence
    cover_success_sequence: cover sequence (success_sequence);


    sequence failure_sequence;
        (`INSTR_WB(l40_li_a2) && instr_will_progress
        ##1 `INSTR_WB(l42_li_a0) && instr_will_progress 
        ##1 `INSTR_WB(l44_cret) 
        );
    endsequence
    cover_failure_sequence: cover sequence (failure_sequence);


    // define checks to see if a capability is unsealed correctly
    logic [32:0] obj_ptr_top = get_top_bound33(obj_ptr, obj_ptr_addr);
    logic [31:0] obj_ptr_base = get_base_bound32(obj_ptr, obj_ptr_addr);
    logic [32:0] expected_top = obj_ptr_top;
    logic [31:0] expected_base = obj_ptr_base + 8; 
    function automatic bit is_correct_unsealed_pointer(reg_cap_t cap, logic [31:0] addr);
        // Check if the unsealed pointer is correct
        // i.e. base is address of the sealed object + 8, 
        // top is the same as the sealed pointer's top
        // address is same as base
        logic is_unsealed = (cap.otype == 3'b000);
        logic [31:0] cap_base = get_base_bound32(cap, addr);
        logic [32:0] cap_top = get_top_bound33(cap, addr);
        logic has_correct_base = ( cap_base >= expected_base);
        logic has_correct_top = (cap_top <= expected_top);
        logic has_correct_address = (addr == cap_base);
        return is_unsealed && has_correct_base && has_correct_top && has_correct_address;   
    endfunction

    // allow ca1 to be exactly the sealed pointer
    logic ca1_ok = ~ca1.valid || (ca1 == obj_ptr && a1 == obj_ptr_addr);
    // allow ca0 to hold the unsealed pointer with correct bounds
    logic ca0_ok = ~ca0.valid || is_correct_unsealed_pointer(ca0, a0);
    
    // check if the unsealing authority is safe (no derivatives anywhere except in the special allowed cases)
    logic us_auth_safe_other_regs = no_derivatives_except_ca0_ca1_fn(us_auth,us_auth_addr);
    logic us_auth_safe_ca1 = ca1_ok || ~derived_from(ca1, a1, us_auth,us_auth_addr);
    logic us_auth_safe_ca0 = ca0_ok || ~derived_from(ca0, a0, us_auth,us_auth_addr);
    logic us_auth_safe = us_auth_safe_other_regs && us_auth_safe_ca1 && us_auth_safe_ca0;

    // check if the object pointer is safe (no derivatives anywhere except in the special allowed cases)
    logic obj_ptr_safe_other_regs = no_derivatives_except_ca0_ca1_fn(obj_ptr, obj_ptr_addr);
    logic obj_ptr_safe_ca1 = ca1_ok || ~derived_from(ca1, a1, obj_ptr, obj_ptr_addr);
    logic obj_ptr_safe_ca0 = ca0_ok || ~derived_from(ca0, a0, obj_ptr, obj_ptr_addr);
    logic obj_ptr_safe = obj_ptr_safe && obj_ptr_safe_ca1 && obj_ptr_safe_ca0;

    // assume that the unsealing authority and object pointer are not leaked at the beginning of the execution
    logic assumption = no_derivatives_except_ca0_ca1_ca2_fn(ca2, a2) && no_derivatives_except_ca0_ca1_ca2_fn(ca1, a1);
    
    property success_path_us_auth_other_regs_prop;
     ( (success_sequence and assumption)
        |-> us_auth_safe_other_regs
        );
    endproperty;
    success_path_us_auth_other_regs: assert property (success_path_us_auth_other_regs_prop);

    property success_path_obj_ptr_other_regs_prop;
        ( (success_sequence and assumption)
        |-> obj_ptr_safe_other_regs
        );
    endproperty;
    success_path_obj_ptr_other_regs: assert property (success_path_obj_ptr_other_regs_prop);

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


    
    // follows from check_ca1_ok
    property success_path_us_auth_ca1_prop;
        ( (success_sequence and no_derivatives_except_ca0_ca1_ca2_fn(ca2, a2))
        |-> us_auth_safe_ca1
        );
    endproperty;
    // success_path_us_auth_ca1: assert property (success_path_us_auth_ca1_prop);

    // follows from check_ca0_ok
    property success_path_us_auth_ca0_prop;
        ( (success_sequence and no_derivatives_except_ca0_ca1_ca2_fn(ca2, a2))
        |-> us_auth_safe_ca0
        );
    endproperty;
    // success_path_us_auth_ca0: assert property (success_path_us_auth_ca0_prop);
    
    // follows from check_ca0_ok and check_ca1_ok and success_path_us_auth_other_regs_prop
    property success_path_us_auth_prop;
        ( (success_sequence and no_derivatives_except_ca0_ca1_ca2_fn(ca2, a2))
        |-> us_auth_safe
        );
    endproperty;
    // success_path_us_auth: assert property (success_path_us_auth_prop);
    
    property check_instr_will_progress;
        (instr_will_progress && wbexc_exists
        |-> ~wbexc_err);
    endproperty
    // check_instr_will_progress_assert: assert property (check_instr_will_progress);

endmodule