/*
    This file defines some shorthands for registers and capabilities used in the tita module.
    It includes definitions for general purpose registers and special status registers
*/


// registers are in `RF.rf_reg
// cap registers are in `RF.rf_cap
// the address of capability in `RF.rf_cap[i] is in `RF.rf_reg[i]
// `INSTR points to the instruction in the wbexc stage
// SCR registers are in `CSR.[reg]_cap where reg in mepc (for mepcc), mtvec (for mtcc)
// mtdc, mscratchc found in `CSRG.[reg]_cap where reg in mtdc, mscratchc

// define general purpose registers
logic [31:0] regs [31:0] = `RF.rf_reg;
// reg_cap_t [31:0] cap_regs = `RF.rf_cap; -> somehow throws error


// define special status registers
reg_cap_t mtdc = `CSRG.mtdc_cap;
reg_cap_t mscratchc = `CSRG.mscratchc_cap;	
reg_cap_t mepcc = `CSR.mepc_cap;
reg_cap_t mtcc = `CSR.mtvec_cap;
pcc_cap_t pcc = `CSR.pcc_cap_o;

logic [31:0] mtdc_addr = `CSRG.mtdc_data;
logic [31:0] mscratchc_addr = `CSRG.mscratchc_data;
logic [31:0] mepcc_addr = `CSR.mepc_q;
logic [31:0] mtcc_addr = `CSR.mtvec_q;


logic [31:0] mstatus = `CSR.mstatus_en_combi;

// define useful capability registers
reg_cap_t csp = `RF.rf_cap[2];
reg_cap_t ct2 = `RF.rf_cap[7];
reg_cap_t cra = `RF.rf_cap[1];
reg_cap_t ca0 = `RF.rf_cap[10];
reg_cap_t ca1 = `RF.rf_cap[11];
reg_cap_t ca2 = `RF.rf_cap[12];
reg_cap_t ca3 = `RF.rf_cap[13];
logic [31:0] csp_addr = `RF.rf_reg[2];
logic [31:0] ct2_addr = `RF.rf_reg[7];
logic [31:0] cra_addr = `RF.rf_reg[1];
logic [31:0] a0 = `RF.rf_reg[10];
logic [31:0] a1 = `RF.rf_reg[11];
logic [31:0] a2 = `RF.rf_reg[12];
logic [31:0] a3 = `RF.rf_reg[13];

logic [31:0] wb_instr = `INSTR;