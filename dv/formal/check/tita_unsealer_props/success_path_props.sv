

// property success_path_us_auth_other_regs_prop;
// ( (success_sequence and assumption)
// |-> us_auth_safe_other_regs
// );
// endproperty;
// success_path_us_auth_other_regs: assert property (success_path_us_auth_other_regs_prop);

// property success_path_obj_ptr_other_regs_prop;
// ( (success_sequence and assumption)
// |-> obj_ptr_safe_other_regs
// );
// endproperty;
// success_path_obj_ptr_other_regs: assert property (success_path_obj_ptr_other_regs_prop);





property success_path_obj_ptr_prop;
( (success_sequence and assumption)
|-> obj_ptr_safe
);
endproperty;
success_path_obj_ptr: assert property (success_path_obj_ptr_prop);

property success_path_us_auth_prop;
    ( (success_sequence and no_derivatives_except_ca0_ca1_ca2_fn(ca2, a2))
    |-> us_auth_safe
    );
endproperty;
success_path_us_auth: assert property (success_path_us_auth_prop);

