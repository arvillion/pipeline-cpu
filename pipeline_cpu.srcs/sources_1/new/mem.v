`timescale 1ns / 1ps

module mem (
    input I_clk,
    input [31:0] I_addr,
    input [31:0] I_write_data,

    input [31:0] I_alu_result,
    output [31:0] O_reg_write_data, // 写入寄存器的数据 either alu result or read from memory

    output O_reg_write,

    input [4:0] I_dest_reg,
    output [4:0] O_dest_reg,

    input [5:0] I_opcode,
    input [5:0] I_funct
);
    // posedge读写
    // TODO: uart
    wire mem_write;
    wire [31:0] read_data;
    wire lw;

    assign O_dest_reg = I_dest_reg;
    assign O_reg_write_data = lw ? read_data : I_alu_result;

    mem_control mem_ctrl_inst(
        .I_opcode(I_opcode),
        .I_funct(I_funct),
        .O_reg_write(O_reg_write),
        .O_lw(lw),
        .O_sw(mem_write)
    );

    data_ram dram_inst(
        .addra(I_addr[15:2]),
        .clka(I_clk),
        .dina(I_write_data),
        .douta(read_data),
        .wea(mem_write)
    );
endmodule
