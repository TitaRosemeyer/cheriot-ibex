# create helper task
task -create Tita_help

# copy all assumes from Step26 of psgen.sv
task -edit Tita_help -copy_assumes -copy {Step26::*}

# assume everything proven in Step26
assume -from_assert {Tita_help::*.Wrap_Priv Tita_help::*.Wrap_Mstatus Tita_help::*.Wrap_Mie Tita_help::*.Wrap_Mcause Tita_help::*.Wrap_Mtval Tita_help::*.Wrap_Mscratch Tita_help::*.Wrap_Mcounteren Tita_help::*.Wrap_Pc Tita_help::*.Wrap_NMIMode Tita_help::*.Wrap_MStack Tita_help::*.Wrap_MStackCause Tita_help::*.Wrap_MStackEpc Tita_help::*.Wrap_Mtvec Tita_help::*.Wrap_Mepc Tita_help::*.Wrap_MscratchC Tita_help::*.Wrap_Pcc Tita_help::*.Wrap_Mtdc Tita_help::*.Wrap_RegA Tita_help::*.Wrap_RegB Tita_help::*.Mem_En Tita_help::*.Mem_SndEn Tita_help::*.Mem_We Tita_help::*.Mem_FstAddr Tita_help::*.Mem_SndAddr Tita_help::*.Mem_FstWData Tita_help::*.Mem_SndWData Tita_help::*.Mem_WTag Tita_help::*.Mem_FstEnd Tita_help::*.Mem_SndEnd}

# add the helpers we want to check
task -edit Tita_help -copy {top.tita.helpers.*}

# create main task
task -create Tita 

# copy everything from helper task (assumptions and properties)
task -edit Tita -copy_assumes -copy {Tita_help::*}

# remove all cover properties from the helper task
cover -remove Tita::*

# assume everything that the helper task proved
assume -from_assert {Tita::top.tita.helpers.*}

# add the properties we want to check
task -edit Tita -copy {top.tita.instructions.*}