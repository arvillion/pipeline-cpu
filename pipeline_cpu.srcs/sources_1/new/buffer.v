`timescale 1ns / 1ps

module buffer(
    input I_clk,
    input I_rst,
    input [23:0] I_switches,
    input I_commit,
    output reg [23:0] O_switches_value
);
    always @(posedge I_clk) begin
        if (I_rst)         O_switches_value <= 0;
        else if (I_commit) O_switches_value <= I_switches;
        else               O_switches_value <= O_switches_value;
    end
endmodule
