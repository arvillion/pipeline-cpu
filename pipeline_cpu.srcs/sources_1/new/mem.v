`timescale 1ns / 1ps

module mem(
    input [31:0] I_addr,
    input [31:0] I_alu_result,
    input [31:0] I_m_read_data, // data read from memory (lw)
    input [23:0] I_switches_data, // TODO data read from switches 
    output [31:0] O_reg_write_data,

    input [4:0] I_dest_reg,
    output [4:0] O_dest_reg,


    input [5:0] I_opcode,
    input [5:0] I_funct,

    input [31:0] I_write_data, // data to write with (sw)
    output [31:0] O_m_write_data,
    output O_m_write,
    output [31:0]  O_m_addr,

    output [15:0] O_io_write_data,
    output O_led_write,
    output O_led_sel,

    output O_reg_write
    
);
    wire is_io_addr, lw, sw;

    assign is_io_addr = (I_addr[31:16] == 16'hffff) ? 1 : 0;

    reg [31:0] m_or_io_data;
    always @* begin
        if (~is_io_addr) m_or_io_data = I_m_read_data;
        else m_or_io_data = {16'b0, I_switches_data[15:0]}; // TODO
    end
    assign O_reg_write_data = lw ? m_or_io_data : I_alu_result;
    assign O_dest_reg = I_dest_reg;

    assign O_m_write_data = I_write_data;
    assign O_m_write = sw & ~is_io_addr;
    assign O_m_addr = I_addr;

    assign O_io_write_data = I_write_data[15:0];
    assign O_led_write = sw & is_io_addr; // TODO
    assign O_led_sel = 0; // TODO

    mem_control mem_ctrl_inst(
        .I_opcode(I_opcode),
        .I_funct(I_funct),
        .O_reg_write(O_reg_write),
        .O_lw(lw),
        .O_sw(sw)
    );
endmodule

module dmemory (
    input I_clk,
    input [31:0] I_addr,
    input [31:0] I_write_data,
    input I_m_write,
    output [31:0] O_read_data
);
    data_ram dram_inst(
        .addra(I_addr[15:2]),
        .clka(I_clk),
        .dina(I_write_data),
        .douta(O_read_data),
        .wea(I_m_write)
    );
endmodule