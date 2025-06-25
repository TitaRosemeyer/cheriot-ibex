lappend ::auto_path [get_install_dir]/etc/res/tcl_library/tcllib-1.21/modules/cmdline
package require cmdline

#####################################################
# Last Modified: Sep 04, 2024
# Compatible with 2024.09-20240904
#####################################################

namespace eval symsim {

set export_procedure {}

variable empty_seq 0

#####################################################
# Expression API
#####################################################

proc TRUE {}  {check_symsim -expression -const 1}
proc FALSE {} {check_symsim -expression -const 0}
lappend export_procedure TRUE FALSE

proc VAR {v} {check_symsim -expression -var $v}
proc NOT {e} {check_symsim -expression -not $e}
proc AND {args} {check_symsim -expression -and $args}
proc OR  {args} {check_symsim -expression -or  $args}
lappend export_procedure VAR NOT AND OR

proc PR  {e} {check_symsim -expression -pretty $e}
proc PR_SEQ {s} {check_symsim -sequence $s -get -verbose}
lappend export_procedure PR PR_SEQ

proc STIM_VAR {v tick_range} {
    list [VAR $v] [NOT [VAR $v]] $tick_range
}
proc STIM_CONST {c tick_range} {
    list $c [NOT $c] $tick_range
}
proc STIM_X {tick_range} {
    list $FALSE $FALSE $tick_range
}
lappend export_procedure STIM_VAR STIM_CONST STIM_X

####################################################
# Get resolved recipe for property
####################################################
lappend export_procedure "get_resolved_recipe"
proc get_resolved_recipe {property} {
    set p [string map {\[ \\\[ ] \\\] \- \\\-} $property]
    set resolved_recipes [check_symsim -resolved_recipe -list]
    foreach r $resolved_recipes {
	set recipe [check_symsim -resolved_recipe -get $r]
	set targets [dict get $recipe cout_config obs_dict]
	foreach {target tick} $targets {
	    if { $property == $target } {
		return $r
	    }
	    if { [string match -nocase *$property* $target] } {
		return $r
	    }
	    if { [string match -nocase *$p* $target] } {
		return $r
	    }
	}
    }
    return ""
}

####################################################
# Procedures to simplify debugging
####################################################
proc exists_window {window} {
    set windows [visualize -list -all_windows -silent]
    if {[lsearch -exact $windows $window] >= 0} {
	return 1
    } else {
	return 0
    }
}

lappend export_procedure "visualize_add_signals"
proc visualize_add_signals {signals {window ""}} {
    if { $window == ""} {
	set window [visualize -get_current_window]
    }
    foreach s $signals {
	visualize -add_sig $s -window $window
    }
}

lappend export_procedure "visualize_sequence"
proc visualize_sequence {sequence {ant_seq 0} {weak_seq 0} {window ""}} {
    variable empty_seq
    if { $empty_seq == 0} {
	set empty_seq [check_symsim -sequence -create]
    }
    if { $window == "" } {
	set window "sequence_$sequence:0"
    }
    if { $ant_seq == 0 } {
	set ant_seq $empty_seq
    }
    if { $weak_seq == 0 } {
	set weak_seq $empty_seq
    }
    if { [exists_window $window] == 1 } {
	visualize -symbolic -sequence $sequence -window $window -antecedent $ant_seq -weakening $weak_seq	
    } else {
	visualize -symbolic  -sequence $sequence -new_window $window  -antecedent $ant_seq -weakening $weak_seq
    }
    set clk [get_clock_info -fastest_clocks]
    if { $clk != "" } {
	visualize -add_sig $clk
    }
    if { $ant_seq != ""} {
	foreach {sig values} [check_symsim -sequence $ant_seq -get] {
	    visualize -add_sig $sig -window $window 
	}
	visualize -add_spacer
    }

    put_message -info "Visualizing sequence $sequence in window $window"
    return $window
}

lappend export_procedure "get_proof_id"
proc get_proof_id {property} {
    set result [check_symsim -prove -get_result]
    set max_id [dict get $result recipe_results proof_id]
    puts "current proof_id is $max_id"
    set id 0
    # find latest proof including given property
    set name [get_property_info $property -list name]
    set full_name "[get_property_info $property -list task]::$name"
	set replaced_name [string map {\[ _ \] _ . _} $name]
    for {set i $max_id} {$i > 0} {incr i -1} {
	set p   [check_symsim -prove $i -get_result]
	if { [string match *$name* $p] || [string match *$full_name* $p] || [string match *$replaced_name* $p] } {
	    set id $i
	    break;
	}
    }
    if { $id == 0 } {
	put_message -error "No proof referring to property $property found. (Max proofID: $max_id)"
    }
    return $id
}

lappend export_procedure "visualize_property"
proc visualize_property {property {ant_seq ""} {weak_seq ""}} {
    set id [get_proof_id $property]
    set res [check_symsim -prove $id -get_result]
    set seq [get_result_sequence -result $res]
    visualize_sequence $seq $ant_seq $weak_seq $property
    visualize_add_signals $property
    visualize_add_signals [get_fanin $property]
}

#######################################################
# Procedures to create antc and antv dictionaries
#######################################################
lappend export_procedure "create_antecedent"
proc create_antecedent {args} {

    set syntax {Syntax: create_antecedent -signal <signal> -tick <tick> [-stimuli <stimuli>]
                          [-stable] [-same] [-update <var_name>]}

    set option_list {
	{signal.arg  "-" "Signal to assign the given stimuli to. Supports wide signals and partial ranges."}
	{tick.arg    "1" "Time tick(s) in which to drive the stimuli. Format: tick, from:to, or tick_list. Default "}
	{stable          "Keep the stimuli stable during the given ticks."}
	{same            "Use the same stimuli for all bits of a signal."}
	{update.arg  "-" "Update the given variable with the specified antecedent"}
	{stimuli.arg "-" {The stimuli is either a single bit, a binary pattern, or a variable name. 
                      If no stimuli is provided then the signal name is used as name for the stimuli.} }
    }
    
    if { [string match "*-help*" $args] == 1 } {
	puts $syntax
	puts "Summary:   creates an antecedent dictionary"
	puts "Returns:   antecedent dictionary (to be used with check_symsim -resolved_recipe)\n"
	puts "Detailed description: creates an antecedent dictionary for the given signal with the given stimuli."
	puts "        If the stimuli is a single bit (0/1) then it is assigned to each bit of the"
	puts "        signal.  If the stimuli is a binary pattern with length 2 or more, then the"
	puts "        length has to match the width of the signal, and each bit is assigned the"
	puts "        corresponding stimuli.  If the stimuli is a string then each bit of the signal"
	puts "        is assign to the stimuli extended with the bit index, e.g., 'stimuli\[0\]'. If"
	puts "        multiple ticks are given and stable is 0, then each stimuli is extended with"
	puts "        information about the tick, e.g., 'stimuli\[0\]@2'.  If the stimuli is 'X' then we"
	puts "        assume all bits of the given signals are driven by X for all ticks."
	puts [::cmdline::usage $option_list]
	return
    }
	
    array set options [::cmdline::getoptions args $option_list $syntax]

    set sig      $options(signal)
    set stimuli  $options(stimuli)
    set ticks    $options(tick)
    set stable   $options(stable)
    set same     $options(same)
    set ant_name $options(update)

    if { $sig == "-" } {
	put_message -error "requires option -signal missing."
	return
    }
	
    # we asume the signal should be X at the given ticks
    if {$stimuli == "X"} {
	set same 1
	set stable 1
    }

    if { $ant_name == "-" } {
	set antecedent {}
    } else {
	puts "updating variables $ant_name"
	upvar 1 $ant_name antecedent
    }
    set F [check_symsim -expression -const false]
    set T [check_symsim -expression -const true]

    set sig_width [get_signal_info -width $sig]

    set tick_list ""
    if {[llength $ticks] == 1 && $stable == 0} {
        # the user gave a tick range (or a single tick)
        # create a list with the all the ticks in this range
        set range [split $ticks ":"]
        set from [lindex $range 0]
        set to [lindex $range end]
        if {$to ne "$"} {
            for {set k $from} {$k <= $to} {incr k} {
                lappend tick_list $k
            }
        } else {
            lappend tick_list $from:$to
        }
    } else {
        set tick_list $ticks
    }

    # want to check if the stimuli is comprised only of 0/1
    set is_const [regexp {^[0-1]*$} $stimuli]
    if {$is_const} {
        set stim_list [split $stimuli {}]
        if {[llength $stim_list] eq 1} {
            set char_vec [string repeat $stimuli $sig_width]
            set stim_list [split $char_vec {}]
        } else {
            if {[llength $stim_list] ne $sig_width } {
                put_message -error "The input stimuli ($stimuli) needs to be the same signal width ($sig ($sig_width)) OR 1 character"
                return
            }
        }
    } else {
        if {[regexp \\$ [lindex $tick_list end]]} {
            put_message -error "Using $ is not supported for variables"
            return
        }

	if {$stimuli eq "-"} {
	    # Create a variable name that is the same as the sig_name
	    # without hiearchical path
	    set stimuli [lindex [get_signal_info -get_signal $sig] 0]
	}
	# check is signal include a bit selector:
	set sig_name [lindex [get_signal_info -get_signal $sig -full] 0]
	if { $same || ($sig_width == 1 && $sig_name == $sig) } {
	    set stim_list [lrepeat $sig_width $stimuli]     
	} else {
	    set bit_list [get_signal_info -bit_blast $sig]
	    set stim_list [lmap v $bit_list {string map [list $sig_name $stimuli] $v}]
	}
    }
    set bit_list [get_signal_info -bit_blast $sig]
    set delim "@"
    foreach k $tick_list {
        foreach stim $stim_list bit $bit_list {
 	    if {$stim eq "0"} {
		dict lappend antecedent $bit [list 0 $k]
	    } elseif {$stim eq "1"} {
		dict lappend antecedent $bit [list 1 $k]
          } else {
	      set var_name ${stim}
	      if { $stable == 0 && [llength $tick_list] > 1} {
		  set var_name "${var_name}${delim}$k"
	      }
	      dict lappend antecedent $bit [list $var_name $k]
          }
        }   
    }
    return $antecedent
}

lappend export_procedure "merge_antecedents"
proc merge_antecedents {args} {
    set ant [dict create]
    foreach a $args {
	dict map {key value} $a {dict append ant $key " $value"}
    }
    return $ant
}

lappend export_procedure "create_antecedent_sequence"
proc create_antecedent_sequence {args} {
    #create_antecedent_sequence -antv <antv> [-antc <antc>] [-antw <antw>] [-weaken_ant 0/1] [-resolve 0/1]
    # Set the defaults
    array set options {-antc "" -antw "" -resolve 1 -weaken_ant 1}

    if { [llength $args] == 0 } {
	put_message -error "create_antecedent_sequence: required argument -antv missing."
	return 
    }
    if { [string index [lindex $args 0] 0] != "-" } {
	set args [linsert $args 0 "-antv"]
    }
    # Read in the arguments
    if { ([llength $args] % 2) != 0 } { put_message -error "create_antecedent_sequence: wrong number of arguments."; return }
    array set options $args
    if { [info exists options(-antv)] == 0 } {
	put_message -error "create_antecedent_sequence: required argument -antv missing."
	return
    }
    set antv    $options(-antv)
    set antc    $options(-antc)
    set antw    $options(-antw)
    set resolve $options(-resolve)
    set weaken_ant  $options(-weaken_ant)

    set TRUE  [check_symsim -expression -const 1]
    set FALSE [check_symsim -expression -const 0]

    set ant [merge_antecedents $antv $antc $antw]

    set antecedent_stimuli [dict create]
    set weakening_stimuli [dict create]
    foreach {sig entries} $ant {
	foreach entry $entries {
	    set value [lindex $entry 0]
	    set range [lindex $entry 1]
	    if { $weaken_ant || $value == "X" } {
		dict lappend weakening_stimuli $sig "$FALSE $FALSE $range"
	    }
	    switch $value {
		"1" {
		    #puts "Setting $sig to true in $range"
		    dict lappend antecedent_stimuli $sig "$TRUE $FALSE $range"
		}
		"0" {
		    #puts "Setting $sig to false in $range"
		    dict lappend antecedent_stimuli $sig "$FALSE $TRUE $range"
		} 
		"X" {
		    #puts "Setting $sig to Z in $range"
		    #dict lappend antecedent_stimuli $sig "$FALSE $FALSE $range"; #all undriven signals are X
		}
		default {
		    #puts "Setting $sig to $value in $range"
		    dict lappend antecedent_stimuli $sig [STIM_VAR $value $range]
		}
	    }
	}
    }

    set antecedent_seq [check_symsim -sequence -create $antecedent_stimuli]
    set weakening_seq  [check_symsim -sequence -create $weakening_stimuli -weak]
    set final_seq $antecedent_seq
    if { $resolve } {
	if { [llength $weakening_seq] > 0 } {
	    set final_seq [check_symsim -sequence -resolve -antecedent $antecedent_seq -weakening $weakening_seq]
	} else {
	    set final_seq [check_symsim -sequence -resolve -antecedent $antecedent_seq]
	}
    } else {
	if { [llength $weakening_seq] > 0 } {
	    put_message -warning "resolve sequence to take weakening into account"
	}
    }
    return $final_seq
}

####################################################
# Procedures to create cin and cout dictionaries
####################################################

lappend export_procedure "create_input_constraint"
proc create_input_constraint {args} {

    ## cin format changed from 2023.12-20231012 onwards
    set version [lindex [split [get_version] "-"] 0]
    set build_date [lindex [get_version -build_date] 0]
    if { ($version < {2023.12}) || ($build_date < {2023.10.12}) } {
	return [create_output_constraint {*}$args]
    }

    # Set the defaults
    array set options {-param true -param_stage 0 -param_substage 0 -comment "none" -update "-"}
    # Read in the arguments
    if { ([llength $args] % 2) != 0 } { put_message -error "Wrong number of arguments."; return }
    array set options $args
    if { [info exists options(-property)] == 0 || 
	 [info exists options(-tick)] == 0 } {
	put_message -error "Required arguments -property or -tick missing."
    }
    set property       $options(-property)
    set ticks          $options(-tick)
    set param          $options(-param)
    set param_stage    $options(-param_stage)
    set param_substage $options(-param_substage)
    set comment        $options(-comment)
    set cin_name       $options(-update)

    if {[llength $ticks] == 1} {
        # the user gave a tick range (or a single tick)
        # create a list with the all the ticks in this range
        set range [split $ticks ":"]
        set from [lindex $range 0]
        set to [lindex $range end]
	for {set k $from} {$k <= $to} {incr k} {
	    lappend tick_list $k
	}
    } else {
        set tick_list $ticks
    }

    if { $cin_name == "-" } {
	set constraints {}
    } else {
	upvar 1 $cin_name constraints
    }
    foreach t $tick_list {
	set constraint [dict create name $property tick $t]
	if { $param != "true"  }    {dict set constraint param $param}
	if { $param_stage != 0 }    {dict set constraint param_stage $param_stage}
	if { $param_substage != 0 } {dict set constraint param_substage $param_substage}
	if { $comment != "none" }   {dict set constraint comment $comment}
	lappend constraints $constraint
    }

    return $constraints
}

lappend export_procedure "merge_input_constraints"
proc merge_input_constraints {args} {
    set constraints [list]
    foreach a $args {
	foreach c $a {
	    lappend constraints $c
	}
    }
    return $constraints
}

lappend export_procedure "create_output_constraint"
proc create_output_constraint {args} {
    # Set the defaults
    array set options {-update "-"}
    # Read in the arguments
    if { ([llength $args] % 2) != 0 } { put_message -error "Wrong number of arguments."; return}
    array set options $args
    if { [info exists options(-property)] == 0 || 
	 [info exists options(-tick)] == 0 } {
	put_message -error "Required arguments -property or -tick missing."
    }
    set property  $options(-property)
    set ticks     $options(-tick)
    set cout_name $options(-update)

    if {[llength $ticks] == 1} {
        # the user gave a tick range (or a single tick)
        # create a list with the all the ticks in this range
        set range [split $ticks ":"]
        set from [lindex $range 0]
        set to [lindex $range end]
	for {set k $from} {$k <= $to} {incr k} {
	    lappend tick_list $k
	}
    } else {
        set tick_list $ticks
    }

    if { $cout_name == "-" } {
	set constraint [dict create]
    } else {
	upvar 1 $cout_name constraint
    }
    dict lappend constraint $property $tick_list

    return $constraint
}

lappend export_procedure "merge_output_constraints"
proc merge_output_constraints {args} {
    set constraints [dict create]
    foreach a $args {
	dict map {key value} $a {dict lappend constraints $key $value}
    }
    return $constraints
}

###################################################
# Procedure to create a weakening dictionary for -recipe -add_wl
###################################################
lappend export_procedure "create_weakening_list"
proc create_weakening_list {args} {
    # Set the defaults
    array set options {-update "-"}
    # Read in the arguments
    if { ([llength $args] % 2) != 0 } { put_message -error "Wrong number of arguments."; return }
    array set options $args
    if { [info exists options(-instance)] == 0 || 
	 [info exists options(-tick)] == 0 } {
	put_message -error "Required arguments -instance or -tick missing."
    }
    set instances $options(-instance)
    set ticks     $options(-tick)
    set wl_name   $options(-update)
    
    if { $wl_name == "-" } {
	set wl_dict {}
    } else {
	upvar 1 $wl_name wl_dict
    }

    foreach inst $instances {
	set inst_inputs [get_design_info -instance $inst -list input -include_hier_path -silent]
	foreach inp $inst_inputs {
	    dict set wl_dict $inp $ticks
	}
    }
    return $wl_dict
}

###################################################
# Procedure to get the final sequence of a proof run
###################################################
# lappend export_procedure "get_sequence"
# proc get_sequence {result} {
#     set proof_id [dict get $result recipe_results proof_id]
#     set intermediate_res [check_symsim -prove -get_result $proof_id -intermediate]
#     set output_seq [dict get $intermediate_res cout_res main_eval_result_seq]
#     return $output_seq
# }

lappend export_procedure "get_result_sequence"
proc get_result_sequence {args} {
    # Set the defaults
    array set options {-result 0 -constraint_type output -proof_phase main_eval_result_seq -param_stage 0}
    # Read in the arguments
    if { ([llength $args] % 2) != 0 } { put_message -error "Wrong number of arguments."; return }
    array set options $args
    set result $options(-result)
    set type   $options(-constraint_type)
    set phase  $options(-proof_phase)
    set stage  $options(-param_stage)

    # get latest result if no result is given
    if { $result == 0 } {
	set result [check_symsim -prove -get_result]
    }
    set proof_id [dict get $result recipe_results proof_id]
    set intermediate_res [check_symsim -prove -get_result $proof_id -intermediate]
    set seq 0
    if { $type == "input" } {
	set seq [dict get $intermediate_res cin_res $stage $phase]
    } else {
	# type == output
	set seq [dict get $intermediate_res cout_res $phase]
    }
    return $seq
} 

####################################################
# Procedure to get resolved recipe for a property
####################################################
lappend export_procedure "get_solved_recipe"
proc get_solved_recipe {property} {
    set recipes [check_symsim -resolved_recipe -list]
    set p_name [get_property_info $property -list name]
    set t_name [get_property_info $property -list task]
    foreach r $recipes {
	set r_details [check_symsim -resolved_recipe -get $r]
	set cout [dict get $r_details cout_config obs_dict]
	set target [lindex $cout 0]
	if { [string match $target $p_name] ||  [string match $target "${t_name}::$p_name"] } {
	    return $r
	}
    }
    put_message -warning "Property $property does not have a resolved recipe."
    return ""
}

####################################################
# Procedure to return the list of variables in the given antecedent
####################################################
lappend export_procedure "get_antecedent_variables"
proc get_antecedent_variables {antv} {
    set vars {}
    foreach v [dict values $antv] { 
	set l [concat {*}$v]
	lappend vars {*}$l
    }
    return [dict keys $vars]
}

####################################################
# Procedure to rename param variables to original variables
####################################################
lappend export_procedure "rename_param_variables"
proc rename_param_variables {expression {param_phase 0}} {
    set depends [check_symsim -expression -depends $expression]
    set subst_dict [dict create]
    foreach v $depends {
	if { [string match "p${param_phase}::*" $v]} {
	    set colon [string first ":" $v]
	    set colon [expr "$colon+2"]
	    set orig_name [string range $v $colon end]
	    set orig_expr [check_symsim -expression -var $orig_name]
	    dict set subst_dict $v $orig_expr
	}
    }

    if { $subst_dict != {} } {
	set e [check_symsim -expression -substitute $expression $subst_dict]
    } else {
	set e $expression
    }
    return $e
}

####################################################
# Procedure to compute fanout and fanin of user visible signals
####################################################

proc get_sig_fanio {args} {
    # Set the defaults
    array set options {-bit_blast 0 -all 0}
    # Read in the arguments
    array set options $args
    set signal    $options(-signal)
    set type      $options(-type)
    set bit_blast $options(-bit_blast)
    set all       $options(-all)

    if { $type == "fanin" } {
	set to_check [check_symsim -model -get_sig_fanin $signal]
    } else {
	set to_check [check_symsim -model -get_sig_fanout $signal]
    }

    set done [list $signal]
    lappend done {*}$to_check

    #puts $to_check
    set fanio {}
    while { [llength $to_check] > 0 } {
	set to_check_next {}
	foreach s $to_check {
	    if {[catch {get_signal_info $s}]} {
		#puts "$s is an internal signal in the SymSim model"
		if { $type == "fanin" } {
		    set s_fo1 [check_symsim -model -get_sig_fanin $s]
		} else {
		    set s_fo1 [check_symsim -model -get_sig_fanout $s]
		}
		set s_fo2 [lmap item $s_fo1 { if {$item ni $done} { set item } else { continue }}]
		lappend to_check_next {*}$s_fo2
		lappend done {*}$s_fo2
		if { $all == 1 } {
		    lappend fanio {*}$s_fo2
		}
	    } else {
		if { [regexp {:tmp_} $s] } {
		    #puts "$s is an internal signal in the Jasper model"
		    if {  $type == "fanin" } {
			lappend fanio {*}[get_fanin $s]
		    } else {
			lappend fanio {*}[get_fanout $s]
		    }
		} else {
		    lappend fanio $s
		}
	    }
	}
	set to_check $to_check_next
    }
    if { $bit_blast == 0 && $all == 0 } {
	set fanio [get_signal_list $fanio]
    }
    return $fanio
}

lappend export_procedure "get_sig_fanout"
proc get_sig_fanout {args} {
    if { [llength $args] == 0 } {
	put_message -error "get_sig_fanout: required argument signal missing"
	return
    }
    if { [string index [lindex $args 0] 0] != "-" } {
	set args [linsert $args 0 "-signal"]
    }
    if { ([llength $args] % 2) != 0 } { 
	put_message -error "get_sig_fanout: Wrong number or order of arguments."
	return 
    }
    if { [string match "*-signal *" $args] == 0 } {
	put_message -error "get_sig_fanout: required argument signal missing."
	return 
    }
    return [get_sig_fanio {*}$args -type fanout]
}

lappend export_procedure "get_sig_fanin"
proc get_sig_fanin {args} {
    if { [llength $args] == 0 } {
	put_message -error "get_sig_fanin: required argumentg signal missing"
	return
    }
    if { [string index [lindex $args 0] 0] != "-" } {
	set args [linsert $args 0 "-signal"]
    }
    if { ([llength $args] % 2) != 0 } { 
	put_message -error "get_sig_fanin: wrong number or order of arguments."
	return 
    }
    if { [string match "*-signal *" $args] == 0 } {
	put_message -error "get_sig_fanin: required argument signal missing."
	return 
    }
    return [get_sig_fanio {*}$args -type fanin]
}

####################################################
# Procedure to compute weakening sequence of last simulation
####################################################
lappend export_procedure "create_weak_sequence"
proc create_weak_sequence {max_tick {user_signals 0} {all 0}} {
    set FALSE [check_symsim -expression -const 0]
    set weak_stimuli [dict create]
    for {set tick 1} {$tick <= $max_tick} {incr tick} {
	set weak_signals [check_symsim -eval -get_last_result \
			      -dynamically_weakened_signals $tick]
	set weak_signals_size [llength $weak_signals]
	put_message -info "Extracting data for simulation tick $tick (size : $weak_signals_size)"

	set cnt 0
	foreach sig $weak_signals {
	    foreach bit [check_symsim -model -get_sig_info $sig -bit_blast] {
		dict lappend weak_stimuli $bit "$FALSE $FALSE $tick"
	    }
	    incr cnt
	    if { $user_signals == 1 } {
		set fo [get_sig_fanout -signal $sig -bit_blast 1 -all $all]
		put_message -info "Size of fanout until user-visible signals of $sig ($cnt/$weak_signals_size): [llength $fo]"
		foreach fo_sig $fo {
		    dict lappend weak_stimuli $fo_sig "$FALSE $FALSE $tick"
		}
	    }
	}
    }
    if { [llength $weak_stimuli] > 0 } {
	set weak_sequence  [check_symsim -sequence -create $weak_stimuli -weak]
    } else {
	set weak_sequence [check_symsim -sequence -create]
    }
    put_message -info "Created weakening sequence $weak_sequence"
    return $weak_sequence
}

lappend export_procedure "debug_proof"
proc debug_proof {args} {
    # Set the defaults
    array set options {-proof_id "last" -constraint_type "cout" -param_stage "last" -antv_seq 0 -add_dynamic_weakening 0}	
    # Read in the arguments
    array set options $args
    set proof_id    $options(-proof_id)
    set type        $options(-constraint_type)
    set param_stage $options(-param_stage)
    set antv_seq    $options(-antv_seq)
    set weaken      $options(-add_dynamic_weakening)

    set seqs_to_visualize [list]
    set result [check_symsim -prove -get_result]
    if { $weaken && $proof_id != [dict get $result recipe_results proof_id] } {
	put_message -warning "debug_proof: the dynamical weakening sequence can only be computed for the latest proof."
	set weaken 0
    }

    if { $proof_id != "last" } {
	set result [check_symsim -prove $proof_id -get_result]
    } 

    set seq [get_result_sequence -result $result -constraint_type output]
    if { $type == "cin" } {
	if { $param_stage == "last" } {
	    if { [dict exist $result recipe_results exit_stage] } {
		set param_stage [dict get $result recipe_results exit_stage]
	    } else {
		put_message -warning "debug_proof: debugging param_stage 0"
		set param_stage 0
	    }
	}
	set seq [get_result_sequence -result $result -constraint_type input -param_stage $param_stage]
    }
    
    lappend seqs_to_visualize $seq
    lappend seqs_to_visualize $antv_seq
    # lappend $seqs_to_visualize [get_result_sequence -result $result -constraint_type output -proof_phase main_eval_resolved_seq]

    if { $weaken } {
	lappend seqs_to_visualize [create_weak_sequence [check_symsim -sequence $seq -length] 1]
	
    }
    visualize_sequence {*}$seqs_to_visualize
}

####################################################
# HELP
####################################################
proc help {{p ""}} {
    if { $p == "" } {
	puts {----------------------------------------}
	puts {Syntax:    symsim::help [<procedure>]}
	puts {}
	puts {Summary:   provides help about the procedures in namespace symsim. Available procedures:}
	foreach p $symsim::export_procedure {
	    puts " - $p" 
	}
    } else {
	switch $p {
	    create_antecedent {
		puts {----------------------------------------}
		puts {Syntax:    create_antecedent -signal <signal> -tick <tick> }
		puts {                            [-stimuli <stimuli>] [-stable] [-same]}
		puts {                            [-update <var_name>]}
		puts {}
		puts {Summary:   creates an antecedent dictionary}
		puts {Returns:   antecedent dictionary (to be used with check_symsim -resolved_recipe)}
		puts {}
		puts {Detailed description: creates an antecedent dictionary for the given signal with the given stimuli}
		puts {-signal <signal>}
		puts {   Signal "signal" will be assign the given stimuli. Supports wide signals and partial ranges.}
		puts {-tick <tick>}
		puts {    The tick in which we want to drive the stimuli: tick_tick, from:to or tick_list.}
		puts {[-stable]}
		puts {   Indicates if the stimuli is stable during the given ticks.}
		puts {[-same]}
		puts {   Indicates if we use the same stimuli for all bits of a signal.}
		puts {[-stimuli <stimuli>]}
		puts {   The value that we want to give to the signal. The stimuli is either a binary pattern or a string.}
		puts {   If the stimuli is only 0 or 1 then the stimuli is assigned to each bit of the signal.}
		puts {   If the stimuli is a binary pattern with length 2 or more, then the length has to match the width }
		puts {   of the signal, and each bit is assigned the corresponding stimuli.}
		puts {   If the stimuli is a string then each bit of the signal is assign to the stimuli extended }
		puts {   with the bit index, e.g., "stimuli[0]". If multiple ticks are given and stable is 0, then }
		puts {   each stimuli is extended with information about the tick, e.g., "stimuli[0]@2".}
		puts {   If the stimuli is "X" then we assume all bits of the given signals are driven by X for all ticks.}
		puts {   If no stimuli is provided then we use the signal name as name for the stimuli.}
		puts {[-update <var_name>]}
		puts {   Update the variable <var_name> with the specified antecedent.}
	    }
	    merge_antecedents {
		puts {----------------------------------------}
		puts {Syntax:    merge_antecedents <ant> <ant> [<ant>]* }
		puts {}
		puts {Summary:   merges the given antecedents}
		puts {Returns:   a merged antecedent}
	    }
	    create_input_constraint {
		puts {----------------------------------------}
		puts {Syntax:    create_input_constraint -property <name> -tick <tick> }
		puts {           [-param true/false] [-param_stage <int>] [-param_substage <int>] [-comment <string>]}
		puts {           [-update <var_name>]}
		puts {}
		puts {Summary:   creates an input constraint (cin)}
		puts {Returns:   cin data structure. If option -update is provided than variable <var_name> is}
		puts {           extended with the specified input constraints.}
	    }
	    merge_input_constraints {
		puts {----------------------------------------}
		puts {Syntax:    merge_input_constraints <cin> <cin> [cin]* }
		puts {}
		puts {Summary:   merges the given input constraints}
		puts {Returns:   a merged cin data structure}
	    }
	    create_output_constraint {
		puts {----------------------------------------}
		puts {Syntax:    create_output_constraint -property <name> -tick <tick> [-update <var_name>]}
		puts {}
		puts {Summary:   creates an output constraints}
		puts {Returns:   cout data structure. If option -update is provided than variable <var_name> is}
		puts {           extended with the specified output constraints.}
	    }
	    merge_output_constraints {
		puts {----------------------------------------}
		puts {Syntax:    merge_output_constraints <cout> <cout> [<cout>]* }
		puts {}
		puts {Summary:   merges the given output constraints }
		puts {Returns:   a merged cout data structure}
	    }
	    create_antecedent_sequence {
		puts {----------------------------------------}
		puts {Syntax:    create_antecedent_sequence [-antv] <antv> [-antc <antc>] [-antw <antw>] [-weaken_ant 0/1] [-resolve 0/1]}
		puts {}
		puts {Summary:   create a sequence (to be use with visualize or eval) from the given antecedent dictionaries}
		puts {-antv <antv>}
		puts {   Antecedent dictionaries with variables (used for signals that are driven symbolically)}
		puts {[-antc <antc>]}
		puts {   Antecedent dictionaries with constants (used for signals that are driven by a constant value)}
		puts {[-antw <antw>]}
		puts {   Antecedent dictionaries with Xs (used for signals that are driven by an X)}
		puts {[-resolve 0/1]}
		puts {   If resolve is 1, the sequence will be resolved. Default value is 1.}
		puts {[-weaken_ant 0/1]}
		puts {   If weaken_ant is 1, the values in antv and antc are "forced" in the simulation, i.e., drivers in the design for these signals are ignored.}
		puts {Returns:   sequence id}
	    }	    
	    visualize_sequence {
		puts {----------------------------------------}
		puts {Syntax:    visualize_sequence sequence [antecedent_sequence] [weakening_sequence] [window]}
		puts {}
		puts {Summary:   visualize the given sequence (using the current model)}
		puts {Returns:   returns the name of the used window}
	    }
	    get_antecedent_variables {
		puts {----------------------------------------}
		puts {Syntax:    get_antecedent_variables antv}
		puts {}
		puts {Summary:   list the variables used in a given antecedent dictionary}
		puts {Returns:   returns a list of variable names}
	    }
	    get_resolved_recipe {
		puts {----------------------------------------}
		puts {Syntax:    get_resolved_recipe property}
		puts {}
		puts {Summary:   find the resolved recipe that includes the given property}
		puts {Returns:   returns the name of a resolved recipe}
	    }
	    get_result_sequence {
		puts {----------------------------------------}
		puts {Syntax:    get_result_sequence [-result <result>] [-constraint_type (input|output)]}
		puts {           [-proof_phase (ncfow_eval_resolved_seq|ncfow_eval_result_seq|ncfow_weak_seq|main_eval_resolved_seq|main_eval_result_seq)]}
		puts {           [-param_stage <int>]}
		puts {}
		puts {Summary:   given the result of a proof run return the requested sequence. If no result is provided, the sequence is extract from the last proof run.}
		puts {Returns:   returns the ID of a sequence}
	    }
	    create_weakening_list {
		puts {----------------------------------------}
		puts {Syntax:    create_weakening_list -instance <instance(s)> -tick <tick>}
		puts {           [-update <wl_dict_name>]}
		puts {}
		puts {Summary:   create a weakening list that can be used with the recipe option -add_wl}
		puts {Returns:   returns a TCL dictionary mapping signals to a list of ticks}
		puts {-instance <instance>}
		puts {   An instance or a list of instances that should be weakened. All inputs of these instances will be weakened}
		puts {-tick <tick>}
		puts {   Tick or list of ticks during which the signals of the given instances should be weakened.}
		puts {[-update <wl_dict_name>]}
		puts {   Update the given weakening dictionary instead of creating a new one.}
	    }
	    get_sig_fanin {
		puts {----------------------------------------}
		puts {Syntax:   get_sig_fanin [-signal] <signal> [-bit_blast (0|1) | -all (0|1)] }
		puts {}
		puts {Summary:  computes the user-visible signals in the fanin of the given signal in the symsim model}
		puts {-signal <signal>}
		puts {   Signal the fanin is computed for}
		puts {-bit_blast (0|1)}
		puts {   Indicates if the signals are bit-blasted, i.e., bits of wide signals}
		puts {   are reported separately. Default value is 0.}
		puts {-all (0|1)}
		puts {   Indicates if also internal signals (*:symsim_syn_*) are included in the list.}
		puts {   Default value is 0. This option automatically sets -bit_blast to 1.}
	    }
	    get_sig_fanout {
		puts {----------------------------------------}
		puts {Syntax:   get_sig_fanout [-signal] <signal> [-bit_blast (0|1) | -all (0|1)] }
		puts {}
		puts {Summary:  computes the user-visible signals in the fanout of the given signal in the symsim model}
		puts {-signal <signal>}
		puts {   Signal the fanin is computed for}
		puts {-bit_blast (0|1)}
		puts {   Indicates if the signals are bit-blasted, i.e., bits of wide signals}
		puts {   are reported separately. Default value is 0.}
		puts {-all (0|1)}
		puts {   Indicates if also internal signals (*:symsim_syn_*) are included in the list.}
		puts {   Default value is 0. This option automatically sets -bit_blast to 1.}
	    }
	    debug_proof {
		puts {----------------------------------------}
		puts {Syntax: debug_proof [-proof_id <id>] [-constraint_type (cin|cout)] [-param_stage <stage>] }
		puts {                    [-add_dynamic_weakening (0|1)] }
		puts {}
		puts {Summary: visualize the simulation output sequence for the given proof stages}
		puts {}
		puts {-proof_id <id>}
		puts {   visualize the results of the given proof id. By default the results of the }
		puts {   most recent proof are visualized.}
		puts {-constraint_type (in|out)}
		puts {   visualize the simulation of the input or output constraints. Default is cout.}
		puts {-param_stage <stage>}
		puts {   visualize the simulation of the give param stage. By default the last }
		puts {   computed param stage is visualized.}
		puts {-add_dynamic_weakening (0|1)}
		puts {   mark the dynamically weakened signals in the sequence. This options is only }
		puts {   available for the most recent proof run.}
	    }
	    default {
		puts {----------------------------------------}
		puts "Arguments of $p"
		info args $p
	    }
	}
    }
}

foreach p $export_procedure {
    namespace export $p
}

}; #end of namespace symsim

#namespace import symsim::*
