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

## Tests

TODO: 以表格的方式罗列出测试方法（仿真、上板）、测试类型（单元、集成）、测试用例描述、测试结果（通过、不通过）；以及最终的测试结论。

## Summary

TODO: 问题及总结：开发过程中遇到的问题、思考、总结





