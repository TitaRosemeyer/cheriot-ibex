# Switcher verification - basic block
As simplifications for a first attempt, let's ignore the sealing aspect, assume that `csp` is a valid capability with sufficient bounds (so loads through it won't trap), assume `!defined(CONFIG_MSHWM)`, and assume that the branches on line 1042 and 1052 are not taken (not an injected fault and we didn't get here via `ecall`, and so lines 1015, 1040, 1048, and 1053 are also dead and can be removed). 

We can, for a first attempt, also probably assume that all registers other than `csp` are zero at the time of entry, just so we don't have sixteen restore instructions at the end. 

So, with those simplifications in place, I think the water-testing task would be:

> Prove that this block of instructions results in the at-entry value of `csp` persisting in `mtdc` but being unreachable, assuming that non-`csp` registers are zero at entry, the general-purpose register file does not hold a capability that could be derived from `csp`'s at-entry value.


```assembly
cspecialw mtdc, csp    
clc ct2, TrustedStack_offset_mepcc(csp) 
clw ra, TrustedStack_offset_mstatus(csp) 
csrw mstatus, ra 
cspecialw mepcc, ct2 
clc cra, TrustedStack_offset_cra(csp) 
clc ct2, TrustedStack_offset_ct2(csp)
clc csp, TrustedStack_offset_csp(csp)
mret
```

- ct2 = 7
- cra = 1
- csp = 2
- ra = 1

```assembly
//l.1027 put csp into SCR mtdc
cspecialw mtdc, csp    
//l.1049 load capability at address csp.base + csp.offset + TrustedStack_offset_mepcc into cap. register ct2
clc ct2, TrustedStack_offset_mepcc(csp) 
//l.1073 load 32-bit value at csp.base + csp.offset + 2^t * TrustedStack_offset_mstatus into lower part of integer register ra
clw ra, TrustedStack_offset_mstatus(csp) 
//l.1074 loads value in integer reegister ra into capability register mstatus
csrw mstatus, ra 
//l.1081 put ct2 into SCR mepcc
cspecialw mepcc, ct2 
// see above but for cra, ct2 and csp respectively
clc cra, TrustedStack_offset_cra(csp) 
clc ct2, TrustedStack_offset_ct2(csp)
clc csp, TrustedStack_offset_csp(csp)
mret
```

Is that a reasonable kind of thing / the kind of challenge you were hoping for? If the `mret` is a step too far, feel free to back off to:

> "`csp`'s at-entry value isn't in the general-purpose register file immediately prior to `mret`."

## Goals to write as properties
- this sequence of instructions is passed through and executed
    - can we assume no interruptions?
    - can we assume there is no mistakes in setup?
- non-csp registers are 0 at entry
- get bounds from capabilities
- a certain capability has sufficient bounds wrt loads
- 
- a certain capability is derivable from another
- memory holds a certain capability
- at a certain memory address, there is a capability
- ASR??
- a value is unreachable



## questions:
- we need specific binary code for each instruction -> are there variable inputs or are they fix in binary?
    - if variable, how do we ensure that they point to the right thing? 
    - is address stored somewhere fix?

- where are exceptions stored / raised? mtval? 
- concrete list of assumptions, example cspecialrw:
  - PCC has PERMIT_ACCESS_SYSTEM_REGISTERS set
  - csp is valid

- how to calculate adress from capability -> generally more information on specific cap. encoding



## overview of answers:

### unreachable
When Wes says ‘unreachable’, I think they mean that this value is not exposed to subsequent code (unless it already existed somewhere in memory, hence the ‘assuming that memory does not already hold a copy of this’ caveat).  Specifically:

 - It was not stored to memory.

 - It is not present in any register.

 - The above two properties are true both for the original value of csp and any capabilities derived from that value.

### csp

With a bit more hand waving / context:

On entry to this block, csp is a capability that refers to the place where we stash the state of the interrupted thread.  This block is the end of the path that resumes the interrupted thread.  It should restore that were stashed on entry (that’s a later property to verify, because it depends on verifying that the entry block stashes things in the correct place and that nothing else modifies them, and that latter property is not quite true on all paths through the switcher and so needs some additional caveats for when it is expected to hold).  That’s a functional-correctness property, which is fairly easy to test (everything would break if it didn’t work, at least in the common cases).  The security property is that the pointer to this save area should not leak, which is (hopefully) a simple dataflow property.  

### TrustedStack_offset_*

The `{Type}_offset_{field}` and `{Type}_size` are generated from some very exciting macros to make sure that their values match the offsets and sizes of things in their C types.  Most of the ones for the switcher are the trusted stack fields.

This is the 
https://github.com/CHERIoT-Platform/cheriot-rtos/blob/main/sdk/core/switcher/tstack.h

The values are set here:
https://github.com/CHERIoT-Platform/cheriot-rtos/blob/main/sdk/core/switcher/trusted-stack-assembly.h

## Capability types
```systemverilog
// bit field widths
  parameter int unsigned ADDR_W    = 32;
  parameter int unsigned TOP_W     = 9;    
  parameter int unsigned TOP8_W    = 8;   // IT8 encoding only
  parameter int unsigned BOT_W     = 9;
  parameter int unsigned CEXP_W    = 4;
  parameter int unsigned CEXP5_W   = 5;   // IT8 encoding only
  parameter int unsigned EXP_W     = 5;
  parameter int unsigned OTYPE_W   = 3;
  parameter int unsigned CPERMS_W  = 6;
  parameter int unsigned PERMS_W   = 12;

  parameter int unsigned REGCAP_W  = 37;
// Compressed (regFile) capability type
  typedef struct packed {
    logic                valid;
    logic [1:0]          top_cor;
    logic                base_cor;
    logic [EXP_W-1   :0] exp;    // expanded
    logic [TOP_W-1   :0] top;
    logic [BOT_W-1   :0] base;
    logic [OTYPE_W-1 :0] otype;
    logic [CPERMS_W-1:0] cperms;
    logic                rsvd;
  } reg_cap_t;

  typedef struct packed {
    logic                valid;
    logic [EXP_W-1   :0] exp;    // expanded
    logic [ADDR_W    :0] top33;
    logic [ADDR_W-1  :0] base32;
    logic [OTYPE_W-1 :0] otype;
    logic [PERMS_W-1: 0] perms;
    logic [1:0]          top_cor;
    logic                base_cor;
    logic [TOP_W-1   :0] top;
    logic [BOT_W-1   :0] base;
    logic [CPERMS_W-1:0] cperms;
    logic [31:0]         maska;
    logic                rsvd;
    logic [31:0]         rlen;
  } full_cap_t; 

  typedef struct packed {
    logic                valid;
    logic [EXP_W-1   :0] exp;    // expanded
    logic [ADDR_W    :0] top33;
    logic [ADDR_W-1  :0] base32;
    logic [OTYPE_W-1 :0] otype;
    logic [PERMS_W-1: 0] perms;
    logic [CPERMS_W-1:0] cperms;
    logic                rsvd;
  } pcc_cap_t;
```

## Commands used
### cspecialw ([CHERI ISA 2020](https://www.cl.cam.ac.uk/techreports/UCAM-CL-TR-951.pdf))
```
cspecialw = cspecialrw cnull, src, cs
```
**Format**: `CSpecialRW cd, scr, cs1`

| 31:25 | 24:20 | 19:15 | 14:12 | 11:7 | 6:0 |
|---    |---    |---    |---    |---   |---  |
|0x1    |`scr`  |`cs1`  |0x0    |`cd`  |0x5b |

**Description**
- Capability register `cd` is set equal to special capability register `scr`, and 
- `scr` is set equal to capability register `cs1` if `cs1` is not `C0`.

### clc: Load Capability via Capability

#### [CHERI ISA 2020](https://www.cl.cam.ac.uk/techreports/UCAM-CL-TR-951.pdf)
**Format**: `CLC cd, rt, offset(cb)`

| 31:26 | 25:21 | 20:16 | 15:11 | 10:0 |
|---    |---    |---    |---    |---   |
|0x36   |`cd`   |`cb`   |`rt`   |`offset`|

**Note**: If the encoded value of `cb` is zero, this instruction will use `DDC` as the `cb` operand

**Description**
- Capability register `cd` is loaded from the memory location specified by `cb.base + cb.offset + rt + offset`. 
- Capability register `cb` must contain a capability that grants permission to load capabilities. 
- The virtual address `cb.base + cb.offset + rt + offset` must be `capability_size` aligned. 
- The bit in the tag memory corresponding to `cb.base + cb.offset + rt + offset` is loaded into the tag bit associated with `cd`.

#### [CHERIoT report 2023](https://www.microsoft.com/en-us/research/wp-content/uploads/2023/02/cheriot-63e11a4f1e629.pdf)

**Format**: `CLC cd, cs1, imm`

| 31:20 |19:15  | 14:12 | 11:7  | 6:0 |
|---    |---    |---    |---    |---  |
|`imm`  |`cs1`  |0x3    |`cd`   |0x3  |

**Description**: 
Capability register `cd` is replaced with the capability located in memory at `cs1.address + imm`, and if `cs1.perms` does not grant `PERMIT_LOAD_CAPABILITY` then `cd.tag` is cleared.

### clw: Load integer via Capability register 

#### [CHERI ISA 2020](https://www.cl.cam.ac.uk/techreports/UCAM-CL-TR-951.pdf)

**Format**: `CLW rd, rt, offset(cb)`

| 31:26 | 25:21 | 20:16 | 15:11 | 10:3 | 2:2 | 1:0 |
|---    |---    |---    |---    |---   |---  |---  |
|0x32   |`rd`   |`cb`   |`rt`   |`offset`|`s`|`t`  |

**Note**: If the encoded value of `cb` is zero, this instruction will use `DDC` as the `cb` operand

**Purpose**
Loads a data value via a capability register, and extends the value to fit the target register

**Description**
The lower part of integer register `rd` is loaded from the memory location specified by `cb.base + cb.offset + rt + 2^t ∗ offset`. Capability register cb must contain a valid capability that grants permission to load data.

The size of the value loaded depends on the value of the `t` field:

- **0** byte (8 bits)
- **1** halfword (16 bits)
- **2** word (32 bits)
- **3** doubleword (64 bits)

The extension behavior depends on the value of the `s` field: 1 indicates sign extend, 0 indicates zero extend. For example, `CLWU` is encoded by setting `s` to 0 and `t` to 2, `CLB` is encoded by setting `s` to 1 and `t` to 0.

#### [CHERIoT report 2023 p77](https://www.microsoft.com/en-us/research/wp-content/uploads/2023/02/cheriot-63e11a4f1e629.pdf#page=77)

- opcode is just `s` and `t` from above with `s=0` and `t=2` for unsigned and word, so `op = 0x2`
**Format**: `CLW rd, cs1, imm`

| 31:20 | 19:15  | 14:12  | 11:7 | 6:0 |
|---    |---     |---     |---   |---  |
|`imm`  |`cs1`   |`op`=0x2|`rd`  |0x3  |

### csrw ([RISC-V manual 1](https://drive.google.com/file/d/1uviu1nH-tScFfgrovvFCrj7Omv8tFtkp/view?pli=1))
```
csrw csr, rs1 = CSRRW x0, csr, rs1
```
**Format**: `CSRRW rd, csr, rs1`

| 31:20 | 29:15 | 14:12 | 11:7  | 6:0   |
|---    |---    |---    |---    |---    |
|`csr`  |`rs1`  |001    |`rd`   |1110011|

- OPCODE: SYSTEM = 1110011
- funct3: CSRRW =  001

**Description**
The `CSRRW` (Atomic Read/Write `CSR`) instruction atomically swaps values in the `CSR`s and integer registers. `CSRRW` reads the old value of the `CSR`, zero-extends the value to `XLEN` bits, then writes it to integer register `rd`. The initial value in `rs1` is written to the `CSR`. If `rd=x0`, then the instruction shall not read the `CSR` and shall not cause any of the side effects that might occur on a `CSR` read.

## Registers
### 


### SCRs (ref [CHERI ISA 2020 p. 149](https://www.cl.cam.ac.uk/techreports/UCAM-CL-TR-951.pdf#page=149) )
Special Capability Registers (SCRs) are similar to CSRs in that they affect special functions such as exception delivery, rather than being general-purpose registers, but have capability rather than integer types. SCRs are therefore accessed via new capability-aware instructions.

The new `CSpecialRW` instruction allows reading and writing special capability registers. When the destination register is 0, the instruction shall not read the special capability register and shall not cause any of the side-effects that might occur on a special capability register read, similar to the standard `csrrw` RISC-V instruction. When the source register is 0, the instruction will not write to the special capability register at all, and so shall not cause any of the side effects that might otherwise occur on a special capability register write, similarly to the standard `csrrs/c` RISC-V instruction.

Table 5.3 lists the SCRs available via that instruction, as well as their values at CPU reset, which will be set in a manner consistent with the description in Section 3.6. Whether a register is initialized to `NULL` or the omnipotent capability, its flags field will be initialized to zero (specifying integer encoding mode).

Where an SCR extends a RISC-V CSR, e.g. MTCC extending mtvec, any read to the CSR shall return the offset of the corresponding SCR. Similarly, any write to the CSR shall set the offset of the SCR to the value written.

| Register | Name                                      | Modes     | Access | Reset | Extends |
|----------|-------------------------------------------|-----------|--------|--------|---------|
| 28       | Machine trap code capability (**MTCC**)   | M         | ASR    | ∞      | mtvec   |
| 29       | Machine trap data capability (**MTDC**)   | M         | ASR    | ∞      | -       |
| 30       | Machine scratch capability (**MScratchC**)| M         | ASR    | ∞      | -       |
| 31       | Machine exception PC capability (**MEPCC**)| M        | ASR    | ∞      | mepc    |


**List of used registers**:
Also see sdk/core/switcher/trusted-stack-assembly.h
- cra
    /**
    * `$c1` / `$cra` used by the ABI as the return address.
    * Not preserved across calls.
    */
    `CRA = CheriRegisterNumberCra = 1`
- csp: capability stack pointer
    /**
    * `$c2` / `$csp` used by the ABI as the stack pointer.
    * Preserved across calls.
    */
    `CSP = CheriRegisterNumberCsp = 2`
- ct2: 
    /**
    * `$c7` / `$ct2` used by the ABI as temporary register.
    * Not preserved across calls.
    */
    `CT2 = CheriRegisterNumberCT2 = 7`
- mtdc: 
    
    /**
    * Machine-mode Tusted Data Capability.
    *
    * Special capability register that contains the memory root capability
    * on boot. Only accessible when PCC has the AccessSystemRegisters
    * permission.  Use by the RTOS to store a capability to the trusted
    * stack.
    */
    `MTDC = CheriRegisterNumberMtdc = 61` 
- mepcc
    /**
    * Machine-mode Exception Program Counter Capability. Special capability
    * register that contains the PCC of the faulting instruction on trap.
    * The address has the same semantics as the RISC-V `mepc` CSR. Only
    * accessible when PCC has the AccessSystemRegisters permission.
    */
    `MEPCC = CheriRegisterNumberMepcc = 63`
- ra
- mstatus: machine status register


