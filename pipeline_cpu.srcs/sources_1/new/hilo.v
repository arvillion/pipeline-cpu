`timescale 1ns / 1ps

module hilo(
    input I_clk,
    input I_rst,
    input I_hi_write,
    input I_lo_write,
    input [31:0] I_hi_write_data,
    input [31:0] I_lo_write_data,

    output [31:0] O_hi_read_data,
    output [31:0] O_lo_read_data
);
    reg [31:0] hi, lo;
    assign O_hi_read_data = hi;
    assign O_lo_read_data = lo;

    always @(negedge I_clk) begin
        if (I_rst) begin
            hi <= 0;
            lo <= 0;
        end
        else begin
            if (I_hi_write) hi <= I_hi_write_data;
            if (I_lo_write) lo <= I_lo_write_data;
        end
    end
endmodule
