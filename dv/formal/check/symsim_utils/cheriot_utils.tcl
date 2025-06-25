# =====================================================================

# ---------------------------------------------------------------------
# Set up the recipe for proving an input/output property of the adder by symsim.
#  - pname     : property name
#  - dyn_wlim  : optionally, a dynamic weakening limit for the main simulation
#  - var_order : optionally, a BDD variable ordering
#
# This procedure assumes that the following global variables are defined:
#  - antv ... antecedent
#  - tick  ... tick in which the inputs are sampled
# ---------------------------------------------------------------------
proc create_recipe {pname {dyn_wlim ""} {var_order ""}} {
    global antv
    global tick

    set full_pname "<embedded>::$pname"   ;# Fully qualified property name
    # Get the name of the precondition that we'll param in. This is the first of the related covers.
    set precond "${full_pname}:precondition1"

    # Recipe name incorporates pname, mapping characters "[", "]", and "." to underscores.
    set rname [string map {\[ _ \] _ . _} $pname]

    # Create the recipe fma__base with these configuration settings
    #  - set Xs on flip-flops that are not constant forever after reset
    #  - canonize input and output constraints for main simulation 
    #  - set dynamic weakening limit for noncausal fanout simulation
    #  - set dynamic weakening limit for main simulation on input constraints
    #  - weaken the antecedent
    put_message -info "Creating recipe cheriot_base_$rname"
    check_symsim -recipe cheriot_base_$rname -config \
	-init_states false \
	-cin_main_canonize true \
	-cout_main_canonize true \
	-cin_ncfow_dyn_wlim 0\
	-cin_main_dyn_wlim 0 \
	-weaken_ant true

    # Retrieve the JG version since recipe and cin format has changed in 2023.12-2023-10-12
    set version [lindex [split [get_version] "-"] 0]
    set build_date [lindex [get_version -build_date] 0]
    if { ($version < {2023.12}) || ($build_date < {2023.10.12}) } {
        check_symsim -recipe cheriot_base_$rname -config -cin_param {include "(.*)"}
    }

    # Input constraints - this is just the precondition of our property.
    # create_input_constraint is defined in symsim_utils.tcl. 
    # Run 'symsim::help create_input_constraint' for more information.
    set cin [create_input_constraint -property $precond -tick [expr $tick+2]]

    # Output contraints - this is the whole property
    # create_output_constraint is defined in symsim_utils.tcl. 
    # Run 'symsim::help create_output_constraint' for more information.
    set cout [create_output_constraint -property $full_pname -tick [expr $tick+2]]

    # Set the dynamic weakening limit, if supplied
    if { $dyn_wlim != "" } {
       check_symsim -recipe cheriot_base_$rname -config -cout_main_dyn_wlim $dyn_wlim
    } else {  
       check_symsim -recipe cheriot_base_$rname -config -cout_main_dyn_wlim 0
    }
    # Set the variable order, if supplied.
    if { $var_order != "" } {
       check_symsim -recipe cheriot_base_$rname -config -var_order $var_order
    } else {
	put_message -warning "No order defined for property $full_pname."
    }

    # Create a resolved recipe from the base recipe
    put_message -info "Creating resolved recipe cheriot_resolved_$rname"
    set fma_resolved [check_symsim -resolved_recipe -create \
                                   -recipe cheriot_base_$rname \
                                   -antv $antv -cin $cin -cout $cout \
			                       -force]
    return cheriot_base_$rname
}

# ---------------------------------------------------------------------
# Some small utilities for accessing BDD variables and doing variable ordering.
# ---------------------------------------------------------------------

# Generate a list of variable names from a bit-vector signal. For example, bit foo.bar.baz[1] will become 
# a variable named "baz[1]". These names are consistent with what is in the antv created by create_antecedent
proc makevars {sig} { 
    set bits [get_signal_info -bit_blast $sig]
    set vars {}
    foreach {bit} $bits {
        set path [split $bit .]
        set len [llength $path]
        set varname [lindex $path $len-1]
	lappend vars $varname
        }
     return $vars
}

# Get a specified segment of a list of variables vs[n:0]
# TODO: there must be a better way, probably using lrange.
proc bits {vs from to} {
set result {}
set start [expr [llength $vs] - 1 - $from]
set end [expr [llength $vs] - 1 - $to]
for {set k $start} {$k <= $end} {incr k} {
    lappend result [lindex $vs $k]
}
return $result
} 

# A little variable ordering utility. 
# Interleaves two equal-length variable lists.
proc interleave {vs1 vs2} {
set ordering {}
foreach {v1} $vs1 {v2} $vs2 {
    lappend ordering $v1
    lappend ordering $v2
    }
return $ordering
}

# A utility to generate variable orderings for cases where there is an exponent-difference shift.
# We have variables for the bits of two 52-bit significands, sgnf1[51:0] and sgnf2[51:0] and 
# a shift amount 1 <= shft <= 52. We want a variable ordering comprising:
#  1) sgnf1[51:52-shft] => the first shft bits of the significant with larger exponent
#  2) sgnf1[51-shft:0] interleaved with sgnf2[51:shft] => the bits that will actually be (integer) added
#  3) sgnf2[shft-1:0] => the remaining bits of the shifted significand 
proc mk_shift_order {sgnf1 sgnf2 shft} {
    set sngf1_prefix [bits $sgnf1 51 [expr 52 - $shft]]
    set interleaved_bits [interleave [bits $sgnf1 [expr 51 - $shft] 0] [bits $sgnf2 51 $shft]]
    set shifted_bits [bits $sgnf2 [expr $shft - 1] 0]
    return [concat $sngf1_prefix $interleaved_bits $shifted_bits]
}
