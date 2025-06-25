# source Symbolic simulation utilities
source check/symsim_utils/symsim_utils.tcl
namespace import symsim::*

# Create a symsim model of the design under verification
check_symsim -model -create

# Enable symbolic schematic viewer
set_sym_schematic_viewer_enable true



# Abbreviations for internal signals appearing in the antecedent
# These are already defined in top.sv or tita_registers.sv, but
# we cannot access logic signals, so we need to point to the concrete
# signals in the design.
set pccperms_4_2 pcc.perms\[4:2\]

## Already defined signals (in top.sv):
# reg_cap_t csp -> current state pointer capability
# logic[31:0] csp_addr -> current state pointer address
# logic[31:0] wb_instr -> bits in the wb stage
# logic wbexc_exists -> bits in the wb stage are live
# logic wbexc_fetch_err -> fetch error in the wb stage
# logic instr_will_progress -> next cycle, the instruction in wb will be replaced by the currently executing instruction


# Just a few sanity checks to make sure we're pointing at the right things.
get_signal_info -get_module $pccperms_4_2       ;# should be the top module
get_signal_info -get_instance csp               ;# should be the instance, {}
get_signal_info -width csp_addr                 ;# check it works for one of the internal signals. Should be 32



# What clock phase do we present the inputs on? This will be the low phase of the first clock cycle, 
# because the flip-flops in the design sample their inputs on the rising edge of the clock. Other timing
# data will be relative to this. 
set tick 2;

# Create antecedents for the signals driving the global assumptions.
# A variable with the same name as the signal is created and assigned to the signal at the given clock tick.
# We are setting this for the low phase of clock cycle 1
set pccperms_antv [create_antecedent -signal $pccperms_4_2 -stimuli pccperms_4_2_v -tick $tick]
set csp_antv [create_antecedent -signal csp -stimuli csp_v -tick $tick]
set csp_addr_antv [create_antecedent -signal csp_addr -stimuli csp_addr_v -tick $tick]

# Merge into a single antecedent for the global assumptions.
set global_assumptions_antv [merge_antecedents $pccperms_antv $csp_antv $csp_addr_antv]

# Create antecedents for the signals describing the instruction in the writeback stage.
# These are the signals that will be used to check that the right instruction is being executed
# and that there is no error or void instruction.
set instr_antv [create_antecedent -signal wb_instr -stimuli wb_instr_v -tick $tick]
set wbexc_exists_antv [create_antecedent -signal wbexc_exists -stimuli wbexc_exists_v -tick $tick]
set wbexc_fetch_err_antv [create_antecedent -signal wbexc_fetch_err -stimuli wbexc_fetch_err_v -tick $tick]

# Merge into a single antecedent for the instruction in the writeback stage.
set wb_instr_antv [merge_antecedents $instr_antv $wbexc_exists_antv $wbexc_fetch_err_antv]

# Create antecedent to describe the isntruction lifecycle.
# This is the signal that will be used to check that the instruction in the writeback stage
# finishes its execution in a timely manner.
# Here, the signal is samples in both clock cycles 1 and 2
set instr_will_progress_antv [create_antecedent -signal instr_will_progress -stimuli instr_will_progress_v -tick "$tick [expr $tick +2]"]

# Merge into a single antecedent for the whole property.

set antv [merge_antecedents $global_assumptions_antv $wb_instr_antv $instr_will_progress_antv]

# ---------------------------------------------------------------------
# Include helpers to create a recipe and a BDD order
# ---------------------------------------------------------------------
source check/symsim_utils/cheriot_utils.tcl

# ---------------------------------------------------------------------
# Little utility to prove an input/output property of the adder.
#
#  - pname     : property name
#  - dyn_wlim  : optionally, a dynamic weakening limit for the main simulation
#  - var_order : optionally, a BDD variable ordering
#
# This returns the proof_id, so that we can subsequently get some of the
# intermediate simulation results for debugging with symbolic visualise 
# and the circuit viewer.
# ---------------------------------------------------------------------

proc run_prove {pname {dyn_wlim ""} {var_order ""} {remove_results 1}} {
    global antv
    global tick

    set resolved_recipe_name [create_recipe $pname $dyn_wlim $var_order]

    # Prove the property
    set result [check_symsim -prove -resolved_recipe $resolved_recipe_name -debug_mode]
    set proof_id [dict get $result recipe_results proof_id]

    # Clean-up proof results
    if { $remove_results == "1" } {
	check_symsim -prove $proof_id -remove_result
	check_symsim -expression -sweep
    }
    
    return $proof_id
}

run_prove top.tita.instructions.line_0
