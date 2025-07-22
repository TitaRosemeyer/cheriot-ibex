source verify.tcl
source check/tita_tasks.tcl
prove -bg -task {Tita_unsealer} -engine_mode auto
stop
# prove -bg -task {Tita} -engine_mode Hp
prove -bg -property {Tita::top.tita.instructions.lines_0_1_concrete} -engine_mode Hp
prove -bg -property {Tita::top.tita.instructions.lines_0_2_concrete} -engine_mode Hp
prove -bg -property {Tita::top.tita.instructions.lines_0_3_concrete} -engine_mode Hp
prove -bg -property {Tita::top.tita.instructions.lines_0_4_concrete} -engine_mode Hp
prove -bg -property {Tita::top.tita.instructions.lines_0_5_concrete} -engine_mode Hp
prove -bg -property {Tita::top.tita.instructions.lines_0_6_concrete} -engine_mode Hp
prove -bg -property {Tita::top.tita.instructions.lines_0_7_concrete} -engine_mode Hp