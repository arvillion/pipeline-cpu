# CS202 Spring Final Project

## Developers

TODO: responsibility

| No       | Name        | Responsibility              | Contributions |
| -------- | ----------- | --------------------------- | ------------- |
| 12010704 | Zhang Zekai | main architecture, pipeline | 33.3333333%   |
| 12010602 | Mo Yancheng | assembly source files       | 33.3333333%   |
| 12010620 | Lai Jianyu  | io                          | 33.3333333%   |

## History

| Version | Date         | Description                                                  |
| ------- | ------------ | ------------------------------------------------------------ |
| v0.1    | May 13, 2022 | Single-cycle cpu                                             |
| v1.0    | May 17, 2022 | The first version of multiple-cycle cpu                      |
| v1.1    | May 19, 2022 | Fix some internal logical bugs and run the led-switch test successfully |
| v1.2    | May 23, 2022 | Broaden the width of io wires to 32 bits                     |
| v1.2.1  | May 24, 2022 | Fix the bugs for bne and beq                                 |
| v1.3    | May 25, 2022 | Add support for mfhi, mflo, mthi, mtlo, mul, mulu            |
| v1.4    | May 25, 2022 | Add support for uart                                         |

## Architecture

### Supported ISA

**R format**: `sll`, `srl`, `sllv`, `srlv`, `sra`, `srav`, `jr`, `add`, `addu`, `sub`, `subu`, `and`, `or`, `xor`, `nor`, `slt`, `sltu`, **`mfhi`, `mflo`, `mthi`, `mtlo`, `mult`, `multu`**

**I format:** `beq`, `bne`, `lw`, `sw`, `addi`, `addiu`, `slti`, `sltiu`, `andi`, `ori`, `xori`, `lui`

**J format**: `jump`, `jal`

### Registers

0-31 registers, pc, **hi and lo** register.

All registers are 32-bit in width.

### Addressing

Von Neumann architecture is adopted, and therefore the instruction memory is separate from the data memory.

Instruction memory: 64kb

Data memory: 64kb

TODO: 外设io的寻址范围，寻址单位

### Others

- **Multiple-cycle CPU with classic 5-stage pipeline**: instruction fetching, instruction decoder, execution, memory access, write back.
- **Solve data hazards by forwarding and stall**: A load-use data hazard requires one stall. For other types of data hazards, the pipeline does not need to be paused thanks to the forwarding mechanism.
- **Solve control hazards by prediction**: The prediction strategy we use is that CPU will always execute the very next instruction (pc+4).

## Ports

TODO: CPU接口：时钟、复位、uart接口（可选）、其他常用IO接口使用说明。

## Structure

TODO:

CPU内部结构

- CPU内部各子模块的接口连接关系图 
- CPU内部子模块的设计说明（模块功能、端口规格及功能说明）

#### ifetch

```verilog
module ifetch(
    input [31:0] I_pc, // current value in pc register
    output [31:0] O_next_pc // prediction of value for next pc
);
```

#### decoder

```verilog
module decoder(
    input [31:0] I_instruction, // instruction
  
    input I_rs_can_forward, // 1 indicates data in rs can be forwarded, 0 otherwise
    input I_rt_can_forward, // 1 indicates data in rt can be forwarded, 0 otherwise
    input I_rs_should_stall, // 1 indicates a stall should be added to obtain the data in rs
    input I_rt_should_stall, // 1 indicates a stall should be added to obtain the data in rt
    input [31:0] I_rs_forward_data, // data in rs, obtained by forwarding
    input [31:0] I_rt_forward_data, // data in rt, obtained by forwarding

    input [31:0] I_rs_data, // current data in rs
    input [31:0] I_rt_data, // current data in rt

    output [31:0] O_imm_extended, // signed or unsigned extended immediate

    // correct content in rs and rt register,
    // either forwarded or normally read
    output [31:0] O_rs_data, // correct data in rs, either from current rs or by forwarding
    output [31:0] O_rt_data, // correct data in rt, either from current rt or by forwarding
    
    input [31:0] I_pc_plus_4, // pc+4
    output [31:0] O_pc_plus_4, // pc+4

    // extracted from the instruction
    output [4:0] O_rs, // rs
    output [4:0] O_rt, // rt
    output [4:0] O_rd, // rd
    output [4:0] O_shamt, // shift amount
    output [5:0] O_opcode, // opcode
    output [5:0] O_funct, // funct

    output O_should_stall, // 1 indicates the pipeline should stall, 0 otherwise
    
    output [31:0] O_jump_target // jump address for j, jal and jr
);
```

#### exe

```verilog
module exe(
    input [31:0] I_rs_data, // data in rs
    input [31:0] I_rt_data, // data in rt
    input [31:0] I_imm_extended, // signed or unsigned extended immediate
    input [4:0] I_shamt, // shift amount

    input [5:0] I_opcode, // opcode
    input [5:0] I_funct, // funct
    input [31:0] I_pc_plus_4, // pc+4
    output [31:0] O_addr_result, // branch address for bne, beq
    output reg [31:0] O_alu_result, // alu result

    input [31:0] I_jump_target, // jump address for j jal jr
    output [31:0] O_corr_target, // correct jump/branch address
    output O_corr_pred, // 1 indicates that branch prediction is correct, 0 otherwise

    // possible destination regs
    input [4:0] I_rt, // rt
    input [4:0] I_rd, // rd

    output [4:0] O_dest_reg, // destination reg

    output O_reg_write, // 1 indicates the insturction need to write registers, 0 otherwise
    output O_is_lw, // 1 indicates the instruction is lw, 0 otherwise
    output [31:0] O_mem_write_data, // data written to memory

    output O_hi_write, // 1 indicates the insturction need to write hi, 0 otherwise
    output O_lo_write, // 1 indicates the insturction need to write lo, 0 otherwise
    output reg [31:0] O_hi_write_data, // data written to hi
    output reg [31:0] O_lo_write_data, // data written to lo

    input [31:0] I_hi_read_data, // data read from hi
    input [31:0] I_lo_read_data // data read from lo

);
```

#### mem

```verilog
module mem(
    input [31:0] I_addr, // address
    input [31:0] I_alu_result, // alu result from the exe module
    input [31:0] I_m_read_data, // data read from memory 
    input [31:0] I_io_read_data, // data read from io
    output [31:0] O_reg_write_data, // data written to registers

    input [4:0] I_dest_reg, // destination register
    output [4:0] O_dest_reg, // destination register

    input [5:0] I_opcode, // opcode
    input [5:0] I_funct, // funct

    input [31:0] I_write_data, // data to write
    output [31:0] O_write_data, // data to write
    output O_m_write, // 1 indicates the instruction need to write memory, 0 otherwise
    output [31:0]  O_m_addr, // memory address
    
    output O_io_write, // 1 indicates the instruction need to write io, 0 otherwise

    output O_reg_write // 1 indicates the insturction need to write registers, 0 otherwise
    
);
```

#### wb

```verilog
module wb(
    input [5:0] I_opcode, // opcode
    input [5:0] I_funct, // funct
    input [31:0] I_write_data, // data written to registers
    input [4:0] I_dest_reg, // destination register

    output O_reg_write, // 1 indicates the insturction need to write registers, 0 otherwise
    output [31:0] O_write_data, // data written to registers
    output [4:0] O_dest_reg // destination register
);
```

#### forward

```verilog
module forward(
    input I_ex_reg_write, // 1 indicates that instruction in the exe stage need to write registers, 0 otherwise
    input I_ex_is_lw, // 1 indicates that instruction in the exe stage is lw, 0 otherwise
    input [4:0] I_ex_dest, // destination register for the instruction in the exe stage

    input I_mem_reg_write, // 1 indicates that instruction in the mem stage need to write registers, 0 otherwise
    input [4:0] I_mem_dest, // destination register for the instruction in the mem stage

    input I_wb_reg_write, // 1 indicates that instruction in the wb stage need to write registers, 0 otherwise
    input [4:0] I_wb_dest, // destination register for the instruction in the wb stage

    input [31:0] I_ex_data, // data in the exe stage
    input [31:0] I_mem_data, // data in the mem stage
    input [31:0] I_wb_data, // data in the wb stage

    input [4:0] I_reg_src, // register that needs forwarding

    output reg O_can_forward, // 1 indicates the register can be forwarded, 0 otherwise
    output reg O_should_stall, // 1 indicates the pipeline should have a stall, 0 otherwise
    output reg [31:0] O_forward_data // data forwarded

);
```

#### regfile

```verilog
module regfile(
    input I_clk, // cpu clock
    input I_rst, // system reset
    input [4:0] I_read_src1, // read source register
    input [4:0] I_read_src2, // read source register
    input [4:0] I_write_dest, // write destination register
    input [31:0] I_write_data, // data to write 
    output [31:0] O_read_data1, // data read from I_read_src1 register
    output [31:0] O_read_data2, // data read from I_read_src2 register
    input I_reg_write // 1 enables writing registers
);
```

#### hilo

```verilog
module hilo(
    input I_clk, // cpu clock
    input I_rst, // system reset
    input I_hi_write, // 1 enables writing hi register
    input I_lo_write, // 1 enables writing lo register
    input [31:0] I_hi_write_data, // data to write to hi
    input [31:0] I_lo_write_data, // data to write to lo

    output [31:0] O_hi_read_data, // data read from hi
    output [31:0] O_lo_read_data // data read from lo
);
```

#### led

```verilog
module led(
    input I_clk, // cpu clock
    input I_rst, // system reset
    input I_write, // 1 enables writing led regs
    input [23:0] I_write_data, // data to write to led regs
    output [23:0] O_led_data // data read from led regs
);
```

#### dmemory

TODO: upg

```verilog
module dmemory (
    input I_clk, // cpu clock
    input [31:0] I_addr, // memory address
    input [31:0] I_write_data, // data to write to memory
    input I_m_write, // memory write enable
    output [31:0] O_read_data, // data read from memory
  
    input I_upg_rst, 
    input I_upg_clk, 
    input I_upg_wen, 
    input [13:0] I_upg_adr, 
    input [31:0] I_upg_dat, 
    input I_upg_done 
);
```



## Tests

TODO: 以表格的方式罗列出测试方法（仿真、上板）、测试类型（单元、集成）、测试用例描述、测试结果（通过、不通过）；以及最终的测试结论。

## Summary

TODO: 问题及总结：开发过程中遇到的问题、思考、总结





