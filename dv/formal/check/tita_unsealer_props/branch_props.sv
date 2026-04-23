

property branch_1_safe_prop;
    (branch_1_l00_cgettag and assumption
    |-> us_auth_safe && obj_ptr_safe
    );
endproperty
branch_1_safe: assert property (branch_1_safe_prop);

property branch_2_safe_prop;
    (branch_2_l06_cgetbase and assumption
    |-> us_auth_safe && obj_ptr_safe
    );
endproperty
branch_2_safe: assert property (branch_2_safe_prop);    

property branch_3_safe_prop;
    (branch_3_l0e_cgetlen and assumption
    |-> us_auth_safe && obj_ptr_safe
    );
endproperty
branch_3_safe: assert property (branch_3_safe_prop);

property branch_4_safe_prop;
    (branch_4_l14_cgetperm and assumption
    |-> us_auth_safe && obj_ptr_safe
    );
endproperty
branch_4_safe: assert property (branch_4_safe_prop);

property branch_5_safe_prop;
    (branch_5_l1e_cunseal and assumption
    |-> us_auth_safe && obj_ptr_safe
    );
endproperty
branch_5_safe: assert property (branch_5_safe_prop);    

property branch_6_safe_prop;
    (branch_6_l28_clw and assumption
    |-> us_auth_safe && obj_ptr_safe
    );
endproperty
branch_6_safe: assert property (branch_6_safe_prop);

property branch_7_safe_prop;
    (branch_7_success and assumption
    |-> us_auth_safe && obj_ptr_safe
    );
endproperty
branch_7_safe: assert property (branch_7_safe_prop);