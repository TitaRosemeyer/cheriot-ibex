# --------------------------------------------------
# SWITCHER TASKS
# --------------------------------------------------


# --------------- SWITCHER HELPERS TASK --------------- #
task -create Tita_switcher_help
# copy all assumes from Step26 of psgen.sv
task -edit Tita_switcher_help -copy_assumes -copy {Step26::*}
# assume everything proven in Step26
assume -from_assert {Tita_switcher_help::*.Wrap_Priv Tita_switcher_help::*.Wrap_Mstatus Tita_switcher_help::*.Wrap_Mie Tita_switcher_help::*.Wrap_Mcause Tita_switcher_help::*.Wrap_Mtval Tita_switcher_help::*.Wrap_Mscratch Tita_switcher_help::*.Wrap_Mcounteren Tita_switcher_help::*.Wrap_Pc Tita_switcher_help::*.Wrap_NMIMode Tita_switcher_help::*.Wrap_MStack Tita_switcher_help::*.Wrap_MStackCause Tita_switcher_help::*.Wrap_MStackEpc Tita_switcher_help::*.Wrap_Mtvec Tita_switcher_help::*.Wrap_Mepc Tita_switcher_help::*.Wrap_MscratchC Tita_switcher_help::*.Wrap_Pcc Tita_switcher_help::*.Wrap_Mtdc Tita_switcher_help::*.Wrap_RegA Tita_switcher_help::*.Wrap_RegB Tita_switcher_help::*.Mem_En Tita_switcher_help::*.Mem_SndEn Tita_switcher_help::*.Mem_We Tita_switcher_help::*.Mem_FstAddr Tita_switcher_help::*.Mem_SndAddr Tita_switcher_help::*.Mem_FstWData Tita_switcher_help::*.Mem_SndWData Tita_switcher_help::*.Mem_WTag Tita_switcher_help::*.Mem_FstEnd Tita_switcher_help::*.Mem_SndEnd}
# add the helpers we want to check
task -edit Tita_switcher_help -copy {top.tita.helpers.*}

# ---------------- MAIN SWITCHER TASK --------------- #
task -create Tita_switcher
task -edit Tita_switcher -copy_assumes -copy {Tita_switcher_help::*}
cover -remove Tita_switcher::*
assume -from_assert {Tita_switcher::top.tita.helpers.*}
task -edit Tita_switcher -copy {top.tita.instructions.*}


# ----------------------------------------------
# UNSEALER TASKS
# ----------------------------------------------

# ---------- UNSEALER HELPERS TASK ----------- #
task -create Tita_unsealer_help
# assume everything from Tita_switcher_help
task -edit Tita_unsealer_help -copy_assumes -copy {Tita_switcher_help::*}
cover -remove Tita_unsealer_help::*
assume -from_assert {Tita_unsealer_help::top.tita.helpers.*}
# add the unsealer helpers we want to check
task -edit Tita_unsealer_help -copy {top.unsealer_props.check_*}
task -edit Tita_unsealer_help -copy {top.unsealer_props.cover_*}


# ----------- MAIN UNSEALER TASK ----------- #
task -create Tita_unsealer
# assume everything from Tita_unsealer_help
task -edit Tita_unsealer -copy_assumes -copy {Tita_unsealer_help::*}
assume -from_assert {Tita_unsealer::top.unsealer_props.check_*}
assume -from_assert {Tita_unsealer::top.unsealer_props.cover_*}
cover -remove Tita_unsealer::*
# add the unsealer properties
task -edit Tita_unsealer -copy {*success_path*}
task -edit Tita_unsealer -copy {*branch_?_safe*}
# task -edit Tita_unsealer -copy {*exception_safe}

# ----------- UNSEALER EXCEPTIONS TASK ----------- #
# add the unsealer properties for exceptions
task  -create Tita_unsealer_exceptions
# assume everything from Tita_unsealer_help
task -edit Tita_unsealer_exceptions -copy_assumes -copy {Tita_unsealer_help::*}
assume -from_assert {Tita_unsealer_exceptions::top.unsealer_props.check_*}
assume -from_assert {Tita_unsealer_exceptions::top.unsealer_props.cover_*}
# cover all unsealer exceptions
cover -remove Tita_unsealer_exceptions::*
# add the properties for exceptions
task -edit Tita_unsealer_exceptions -copy {top.unsealer_props.no_wbexc_err_*}

