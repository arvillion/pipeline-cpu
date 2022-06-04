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
| v1.5    | Jun 1, 2022  | Add support for 7-seg tube, keyboard and VGA                 |
| v1.6    | Jun 2, 2022  | Final version                                                |

## Architecture

### Supported ISA

**R format**: `sll`, `srl`, `sllv`, `srlv`, `sra`, `srav`, `jr`, `add`, `addu`, `sub`, `subu`, `and`, `or`, `xor`, `nor`, `slt`, `sltu`, **`mfhi`, `mflo`, `mthi`, `mtlo`, `mult`, `multu`**

**I format:** `beq`, `bne`, `lw`, `sw`, `addi`, `addiu`, `slti`, `sltiu`, `andi`, `ori`, `xori`, `lui`

**J format**: `jump`, `jal`

### Registers

0-31 registers, pc, **hi and lo** register.

All registers are 32-bit in width.

### Address

Von Neumann architecture is adopted, and therefore the instruction memory is separate from the data memory.

Instruction memory: 64kb

Data memory: 64kb

Address byte: byte

Address for IO:

| IO name        | type   | range                | function                                                     |      |
| -------------- | ------ | -------------------- | ------------------------------------------------------------ | ---- |
| switches       | input  | FFFF FXXX$^1$        | input the bits CPU needs read                                |      |
| mini keyboard  | input  | FFFF EXXX            | input the bits CPU needs read                                |      |
| led            | output | FFFF FXXX            | show the data from CPU                                       |      |
| 7 segment tube | output | FFFF FXXX            | show the data of the mini keyboard                           |      |
| VGA            | output | FFFF F000 ~FFFF F960 | show more data from CPU with  promotion hint and stored data for test case |      |
|                |        |                      |                                                              |      |

$^1$ X  means don’t care 

### Others

- **Multiple-cycle CPU with classic 5-stage pipeline**: instruction fetching, instruction decoder, execution, memory access, write back.
- **Solve data hazards by forwarding and stall**: A load-use data hazard requires one stall. For other types of data hazards, the pipeline does not need to be paused thanks to the forwarding mechanism.
- **Solve control hazards by prediction**: The prediction strategy we use is that CPU will always execute the very next instruction (pc+4).

## Ports

- clock
- 4 buttons
- 24 switches
- 24 leds
- 7-seg display
- keyboard
- uart
- VGA

```verilog
module cpu(
    input I_clk_100M, // clock
    input I_rst, // reset
    input [23:0] I_switches, // switches
    
    input I_rx, //  receive data by uart
    output O_tx, // send data by uart
    input start_pg, // used to start communcation mode
    
    input [3:0] I_keyboard_cols, //keyboard
    output [3:0] O_keyboard_rows, //keyboard
    
    output [23:0] O_leds, // leds
    output [7:0] O_seg_en, // seven segment digital tube enable signal
    output [7:0] O_num, // seven segment digital tube
    
    input I_clear, // button that clear the buffer of keyboard
    input I_commit, // button that commits the buffer of keyboard

    output O_hs, // hsync signal
    output O_vs, // vsync signal
    output [11:0] O_rgb444 // rgb
);  
```

## Structure

TODO:

CPU内部结构

- CPU内部各子模块的接口连接关系图 
- CPU内部子模块的设计说明（模块功能、端口规格及功能说明）

#### ifetch

This module makes a prediction for the coming pc value.

```verilog
module ifetch(
    input [31:0] I_pc, // current value in pc register
    output [31:0] O_next_pc // prediction of value for next pc
);
```

#### decoder

This module extract fields from the instruction, and get necessary register values to get prepared for the next few stages.

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

This module will do some arithmetic and logical operations, and check whether the branch prediction is correct or not.

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

This module is actually what we call `memorio`. It will direct the output in the last stage(exe) to either io or data memory modules.

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

The registers will be written in this stage, if necessary.

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

The decoder needs to obtain values from registers according to the instruction. And this module can forward data to the need stages.

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

0-31 registers 

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

hi and lo registers

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

```verilog
module dmemory (
    input I_clk, // cpu clock
    input [31:0] I_addr, // memory address
    input [31:0] I_write_data, // data to write to memory
    input I_m_write, // memory write enable
    output [31:0] O_read_data, // data read from memory
  
    input I_upg_rst, // UPG reset (Active High)
    input I_upg_clk, //UPG ram_clk_i (10MHz)
    input I_upg_wen, //UPG write enable
    input [13:0] I_upg_adr, //UPG write address
    input [31:0] I_upg_dat, //UPG write data
    input I_upg_done //1 if programming is finished
);
```
#### anti shake module for button:

```verilog
module anti_shake_single(
    input I_key,//input signal
    input I_clk,//clock
    input I_rst_n,//reset signal
    output O_key//signal after anti shake treatment
);
```


#### keyboard_top

```verilog
module keyboard_top(
    input I_clk_25M, //clock of 25MHz
    input I_rst, //reset signal
    input I_commit, //commit the current data to io read data
    input [3:0] I_keyboard_cols, //keyboard
    output [3:0] O_keyboard_rows, //keyboard
    output [31:0] O_display, //the data showed in the seven segment tube
    output [31:0] O_read_data //the data commit to io read data
);
```

#### seven_seg

```verilog
module seven_seg(
    input I_clk, //clock
    input I_rst, //reset
    input I_write, //I write
    input [31:0] I_write_data, //the data need to represent
    output reg [7:0] O_num, //seven segment digital tube
    output reg [7:0] O_seg_en //seven segment digital tube enable signal
);
```

#### VGA

```verilog
module vga(
    input I_clk_25M, // clock of 25MHz
    input I_rst_n, // reset, negative active
    output reg [11:0] O_rgb444, // rgb
    output reg O_hs, // hsync
    output reg O_vs, // vsync

    input [11:0] I_pixel_data, // pixel data
    output [9:0] O_pixel_x, // X coordinate
    output [9:0] O_pixel_y // Y coordinate
);
```

#### text_gen

Generate text on screen using VGA text mode.

```verilog
module text_gen(
    input I_clk, // clock
    input [9:0] I_pixel_x, // X coordinate
    input [9:0] I_pixel_y, // Y coordinate
    output [11:0] O_pixel_data, // pixel data

    output [11:0] O_vga_ram_addr, // vga ram address
    input [15:0] I_vga_ram_data // data from vga ram
);
```


## Tests

TODO: 以表格的方式罗列出测试方法（仿真、上板）、测试类型（单元、集成）、测试用例描述、测试结果（通过、不通过）；以及最终的测试结论。

| num  | method                  | type      | describe       | result |
| ---- | ----------------------- | --------- | -------------- | ------ |
| 1    | using development board | integrate | test case 1    | pass   |
| 2    | using development board | integrate | test case 2    | pass   |
| 3    | using development board | integrate | test for mult  | pass   |
| 4    | using development board | integrate | test for multu | pass   |
| 5    | using development board | unit      | test for stall | pass   |
|      |                         |           |                |        |

We pass the test case 1 and test case 2 to check the basic function for the CPU and corresponding IO devices. After that, we test the additional ISA include  `mfhi`, `mflo`, `mthi`, `mtlo`, `mult`, `multu`. In the end, we use unit test to check the stall function for the pipeline CPU.

All in all, all the output of the tests is the same with our expectation.



## Summary

TODO: 问题及总结：开发过程中遇到的问题、思考、总结





