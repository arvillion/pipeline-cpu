`timescale 1ns / 1ps

module forward(
    input I_ex_reg_write,
    input I_ex_is_lw, // memory load
    input [4:0] I_ex_dest,

    input I_mem_reg_write,
    input [4:0] I_mem_dest,

    input I_wb_reg_write,
    input [4:0] I_wb_dest,

    input [31:0] I_ex_data,
    input [31:0] I_mem_data,
    input [31:0] I_wb_data,

    input [4:0] I_reg_src,

    output reg O_can_forward,
    output reg O_should_stall,
    output reg [31:0] O_forward_data

);
    wire ex_reg_write_not_lw;
    assign ex_reg_write_not_lw = I_ex_reg_write & ~I_ex_is_lw;

    always @(*) begin
        if (I_reg_src == 0) begin
            O_forward_data = 0;
            O_can_forward = 0;
            O_should_stall = 0;
        end
        else if (I_reg_src == I_ex_dest && ex_reg_write_not_lw) begin
            O_forward_data = I_ex_data;
            O_can_forward = 1;
            O_should_stall = 0;
        end
        else if (I_reg_src == I_ex_dest && I_ex_is_lw) begin
            O_forward_data = 0;
            O_can_forward = 0;
            O_should_stall = 1;
        end
        else if (I_reg_src == I_mem_dest && I_mem_reg_write) begin
            O_forward_data = I_mem_data;
            O_can_forward = 1;
            O_should_stall = 0;
        end
        else if (I_reg_src == I_wb_dest && I_wb_reg_write) begin
            O_forward_data = I_wb_data;
            O_can_forward = 1;
            O_should_stall = 0;
        end
        else begin
            O_forward_data = 0;
            O_can_forward = 0;
            O_should_stall = 0;
        end
    end
endmodule
