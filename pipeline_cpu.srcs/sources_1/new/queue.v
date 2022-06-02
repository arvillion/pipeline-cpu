`timescale 1ns / 1ps

module queue(
    input I_clk,
    input I_rst,
    input I_commit,
    input next,
    input [3:0] value,
    output reg [31:0] O_keyboard_value,
    output reg [31:0] O_read_data_value
    );
    reg[31:0] count;
    always @(posedge I_clk)begin
        if(I_rst)begin
            O_keyboard_value<=32'b0;
        end
        else if(next & (count==0))begin
            O_keyboard_value <= (O_keyboard_value<<4) + value;
            count <= count +1'b1;
        end
        else if(next& (count!=1200000))begin
            count <= count +1'b1;
        end
        else begin
            O_keyboard_value <= O_keyboard_value;
            count <= 0;
        end
    end
    always @(posedge I_clk)begin
        if(I_rst)begin
            O_read_data_value<=32'b0;
        end
        else if(I_commit)begin
            O_read_data_value <= O_keyboard_value;
        end
        else begin
            O_read_data_value <= O_read_data_value;
        end
    end
endmodule
