`timescale 1ns / 1ps

module mem(
    input [31:0] I_addr,
    input [31:0] I_alu_result,
    input [31:0] I_m_read_data, // data read from memory 
    input [31:0] I_io_read_data, // data read from io
    output [31:0] O_reg_write_data, // to wb

    input [4:0] I_dest_reg,
    output [4:0] O_dest_reg,

    input [5:0] I_opcode,
    input [5:0] I_funct,

    input [31:0] I_write_data, // data to write with (sw)
    output [31:0] O_write_data, // = I_write_data
    output O_m_write, // memory write enable
    output [31:0]  O_m_addr,
    
    output O_io_write, // io write enable

    output O_reg_write
    
);
    wire is_io_addr, lw, sw;

    assign is_io_addr = (I_addr[31:16] == 16'hffff) ? 1 : 0;

    wire [31:0] m_or_io_data = is_io_addr ? I_io_read_data : I_m_read_data;

    assign O_reg_write_data = lw ? m_or_io_data : I_alu_result;
    assign O_dest_reg = I_dest_reg;

    assign O_write_data = I_write_data;
    assign O_m_write = sw & ~is_io_addr;
    assign O_m_addr = I_addr;
    assign O_io_write = sw & is_io_addr;

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
    output [31:0] O_read_data,
  
    input I_upg_rst,
    input I_upg_clk, 
    input I_upg_wen, 
    input [13:0] I_upg_adr, 
    input [31:0] I_upg_dat, 
    input I_upg_done 
);
    wire clk = !I_clk;
    wire kickOff = I_upg_rst | (~I_upg_rst & I_upg_done);
    
    data_ram dram_inst(
        .addra(kickOff ? I_addr[15:2]:I_upg_adr),
        .clka(kickOff ? clk:I_upg_clk),
        .dina(kickOff ? I_write_data:I_upg_dat),
        .douta(O_read_data),
        .wea(kickOff ? I_m_write:I_upg_wen)
    );
endmodule