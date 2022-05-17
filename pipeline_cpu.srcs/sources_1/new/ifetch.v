`timescale 1ns / 1ps
module ifetch(
    input [31:0] I_pc, // 当前pc
    input [31:0] O_next_pc // pc+4
);
    assign O_next_pc = I_pc + 4;
endmodule
