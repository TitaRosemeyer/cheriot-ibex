source verify.tcl
source check/tita_tasks.tcl
prove -property {Tita_unsealer::*precondition1} -bg 
prove -property {Tita_unsealer::*branch_?_safe} -bg -engine_mode Hp
stop
# prove -bg -task {Tita} -engine_mode Hp
prove -bg -property {Tita::top.tita.instructions.lines_0_?_concrete} -engine_mode Hp