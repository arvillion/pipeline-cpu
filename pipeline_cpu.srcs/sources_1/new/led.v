`timescale 1ns / 1ps

module led(
    input I_clk,
    input I_rst,
    input I_write,
    input I_sel,
    input [15:0] I_write_data,
    output [23:0] O_led_data
);
    reg [23:0] led_data;
    assign O_led_data = led_data;
    
    always @(posedge I_clk) begin
        if (I_rst == 1'b1) led_data <= 24'b0;
        else if (I_write == 1'b1)
            if (I_sel == 1'b0) led_data[15:0] <= I_write_data;
            else led_data[23:16] <= I_write_data[7:0];
        else led_data <= led_data;
    end
endmodule
