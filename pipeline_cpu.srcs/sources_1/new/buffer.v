`timescale 1ns / 1ps

module buffer(
    input I_clk,
    input I_rst,
    input [31:0] I_switches,
    input I_commit,
    output reg [31:0] O_switches_value
    );
    always @(posedge I_clk)begin
      if(I_rst)begin
          O_switches_value<=32'b0;
      end
      else if(I_commit)begin
          O_switches_value<=I_switches;
      end
      else begin
          O_switches_value<=O_switches_value;
      end
    end

    
endmodule
