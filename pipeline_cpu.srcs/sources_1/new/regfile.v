`timescale 1ns / 1ps
module regfile(
    input I_clk, // cpu clk
    input I_rst,
    input [4:0] I_read_src1,
    input [4:0] I_read_src2,
    input [4:0] I_write_dest,
    input [31:0] I_write_data,
    output [31:0] O_read_data1,
    output [31:0] O_read_data2,
    input I_reg_write
);
    reg [31:0] regs[0:31];
    integer i;
    // TODO: posedge is ok?
	always @(posedge I_clk) begin
        if (I_rst) 
            for (i = 0; i < 31; i = i+1) regs[i] <= 32'b0;
        else
            if (I_reg_write) 
                regs[I_write_dest] <= I_write_data;
    end

    assign O_read_data1 = I_read_src1 == 0 ? 0 : regs[I_read_src1];
    assign O_read_data2 = I_read_src2 == 0 ? 0 : regs[I_read_src2];
endmodule
