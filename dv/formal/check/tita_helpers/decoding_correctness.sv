// Define a property for instruction decoding correctness
property instruction_decoding_correctness(logic [31:0] instr_in, logic [31:0] instr_out);
    (`CR.if_stage_i.compressed_decoder_i.instr_i == instr_in && instr_will_progress)
    |-> (`IF.instr_out == instr_out);
endproperty

