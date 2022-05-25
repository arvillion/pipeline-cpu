`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2022/05/21 14:42:01
// Design Name: 
// Module Name: keyboard
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module keyboard (
  input I_clk,
  input I_rst,
  input I_write, 
  output reg[31:0] O_read_data,
  input[3:0] I_cols,
  output reg[3:0] O_rows

);


  parameter NO_KEY = 4'd0; 
  parameter MIGHT_HAVE_KEY = 4'd1; 
  parameter SCAN_ROW0 = 4'd2; 
  parameter SCAN_ROW1 = 4'd3;
  parameter SCAN_ROW2 = 4'd4; 
  parameter SCAN_ROW3 = 4'd5; 
  parameter YES_KEY = 4'd6;
  
  // fsm
  reg[3:0] state;
  reg[15:0] count;
  reg[31:0] data;

  always @(posedge I_clk) begin
    if (I_rst == 1'b1) begin
      state <= NO_KEY;
      O_rows <= 4'b0000;
      count <= 16'd0;
      data <= 32'hffffffff;
    end else begin
      case (state)
        NO_KEY:begin
          O_rows <= 4'b0000;
          count <= 16'd0;
          if(I_cols != 4'b1111)begin
            state <= MIGHT_HAVE_KEY;
          end
        end 
        MIGHT_HAVE_KEY:begin
          if(count != 20000)begin
            count <= count + 16'd1;  
          end else if(I_cols == 4'b1111) begin
            state <= NO_KEY;
            count <= 16'd0;
          end else begin
            O_rows <= 4'b1110;
            state <= SCAN_ROW0;
          end
        end
        SCAN_ROW0:begin
          if(I_cols == 4'b1111)begin 
            O_rows <= 4'b1101;
            state <= SCAN_ROW1;
          end 
          else begin
            state <= NO_KEY;
            if(I_cols == 4'b1110)begin
              data <= 32'd13;
            end else if(I_cols == 4'b1101) begin
              data <= 32'd12;
            end else if(I_cols == 4'b1011) begin
              data <= 32'd11;
            end else if(I_cols == 4'b0111) begin
              data <= 32'd10;
            end
          end   
        end
        SCAN_ROW1:begin
          if(I_cols == 4'b1111)begin
            O_rows <= 4'b1011;
            state <= SCAN_ROW2;
          end else begin
            state <= NO_KEY;
            if(I_cols == 4'b1110)begin
              data <= 32'd15;
            end else if(I_cols == 4'b1101) begin
              data <= 32'd9;
            end else if(I_cols == 4'b1011) begin
              data <= 32'd6;
            end else if(I_cols == 4'b0111) begin
              data <= 32'd3;
            end
          end           
        end
        SCAN_ROW2:begin
          if(I_cols == 4'b1111)begin
            O_rows <= 4'b0111;
            state <= SCAN_ROW3;
          end else begin
            state <= NO_KEY;
            if(I_cols == 4'b1110)begin
              data <= 32'd0;
            end else if(I_cols == 4'b1101) begin
              data <= 32'd8;
            end else if(I_cols == 4'b1011) begin
              data <= 32'd5;
            end else if(I_cols == 4'b0111) begin
              data <= 32'd2;
            end
          end          
        end
        SCAN_ROW3:begin
          if(I_cols == 4'b1111)begin
            O_rows <= 4'b0000;
            state <= NO_KEY;
          end else begin
            state <= NO_KEY;
            if(I_cols == 4'b1110)begin
              data <= 32'd14;
            end else if(I_cols == 4'b1101) begin
              data <= 32'd7;
            end else if(I_cols == 4'b1011) begin
              data <= 32'd4;
            end else if(I_cols == 4'b0111) begin
              data <= 32'd1;
            end
          end           
        end
        YES_KEY:begin
          if( {O_rows,I_cols} == 8'b11101110)begin
            data <= 32'd13;
          end else if( {O_rows,I_cols} == 8'b11101101)begin
            data <= 32'd12;
          end else if( {O_rows,I_cols} == 8'b11101011)begin
            data <= 32'd11;
          end else if( {O_rows,I_cols} == 8'b11100111)begin
            data <= 32'd10;
          end else if( {O_rows,I_cols} == 8'b11011110)begin
            data <= 32'd15;
          end else if( {O_rows,I_cols} == 8'b11011101)begin
            data <= 32'd9;
          end else if( {O_rows,I_cols} == 8'b11011011)begin
            data <= 32'd6;
          end else if( {O_rows,I_cols} == 8'b11010111)begin
            data <= 32'd3;
          end else if( {O_rows,I_cols} == 8'b10111110)begin
            data <= 32'd0;
          end else if( {O_rows,I_cols} == 8'b10111101)begin
            data <= 32'd8;
          end else if( {O_rows,I_cols} == 8'b10111011)begin
            data <= 32'd5;
          end else if( {O_rows,I_cols} == 8'b10110111)begin
            data <= 32'd2;
          end else if( {O_rows,I_cols} == 8'b01111110)begin
            data <= 32'd14;
          end else if( {O_rows,I_cols} == 8'b01111101)begin
            data <= 32'd7;
          end else if( {O_rows,I_cols} == 8'b01111011)begin
            data <= 32'd4;
          end else if( {O_rows,I_cols} == 8'b01110111)begin
            data <= 32'd1;
          end else begin
            data <= 32'hffffffff;
          end
          state <= NO_KEY;
        end
        default: begin
          state <= NO_KEY;
        end
      endcase
    end
  end

  always @(*)begin
    if(I_rst == 1'b1) begin
      O_read_data <= 32'b0;
    end 
    else if (I_write ==1'b1) begin
      O_read_data <= data;
    end 
    else begin
      O_read_data <= 32'b0;
    end
  end

endmodule
