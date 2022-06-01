`timescale 1ns / 1ps

module keyboard (
  input I_clk,
  input I_rst,
  output reg[3:0] display,
  input[3:0] I_cols,
  output reg O_led,
  output reg[3:0] O_rows
);
 

  parameter NO_KEY = 4'd0;
  parameter MIGHT_HAVE_KEY = 4'd1;
  parameter SCAN_ROW0 = 4'd2; 
  parameter SCAN_ROW1 = 4'd3;
  parameter SCAN_ROW2 = 4'd4; 
  parameter SCAN_ROW3 = 4'd5;
//  parameter YES_KEY = 4'd6;  
  // fsm
  reg[2:0] state;
  reg[15:0] count;
  reg led;
  reg[3:0] data;
  always @(posedge I_clk) begin
    if (I_rst) begin
      state <= NO_KEY;
//      O_YES_key <= 1'b0;
      O_rows <= 4'b0000;
      count <= 16'd0;
      data <= 4'h0;
      led <= 1'b0;
    end else begin
      case (state)
        NO_KEY:begin
          O_rows <= 4'h0;
          count <= 16'd0;
          led <= 1'b0;
          if(I_cols != 4'b1111)begin
            state <= MIGHT_HAVE_KEY;
          end
        end 
        MIGHT_HAVE_KEY:begin
          if(count != 30000)begin
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
            led <= 1'b1;
            if(I_cols == 4'b1110)begin
              data <= 4'd13;
            end else if(I_cols == 4'b1101) begin
              data <= 4'd12;
            end else if(I_cols == 4'b1011) begin
              data <= 4'd11;
            end else if(I_cols == 4'b0111) begin
              data <= 4'd10;
            end
          end   
        end
        SCAN_ROW1:begin
          if(I_cols == 4'b1111)begin
            O_rows <= 4'b1011;
            state <= SCAN_ROW2;
          end else begin
            state <= NO_KEY;
            led <= 1'b1;
            if(I_cols == 4'b1110)begin
              data <= 4'd15;
            end else if(I_cols == 4'b1101) begin
              data <= 4'd9;
            end else if(I_cols == 4'b1011) begin
              data <= 4'd6;
            end else if(I_cols == 4'b0111) begin
              data <= 4'd3;
            end
          end           
        end
        SCAN_ROW2:begin
          if(I_cols == 4'b1111)begin
            O_rows <= 4'b0111;
            state <= SCAN_ROW3;
          end else begin
            state <= NO_KEY;
            led <= 1'b1;
            if(I_cols == 4'b1110)begin
              data <= 4'd0;
            end else if(I_cols == 4'b1101) begin
              data <= 4'd8;
            end else if(I_cols == 4'b1011) begin
              data <= 4'd5;
            end else if(I_cols == 4'b0111) begin
              data <= 4'd2;
          end          
        end
        end
        SCAN_ROW3:begin
          if(I_cols == 4'b1111)begin
            O_rows <= 4'b0000;
            state <= NO_KEY;
          end else begin
            state <= NO_KEY;
            led <= 1'b1;
            if(I_cols == 4'b1110)begin
              data <= 4'd14;
            end else if(I_cols == 4'b1101) begin
              data <= 4'd7;
            end else if(I_cols == 4'b1011) begin
              data <= 4'd4;
            end else if(I_cols == 4'b0111) begin
              data <= 4'd1;
            end
          end           
        end
                default: begin
                  state <= NO_KEY;
                end
          endcase
        end
      end
  reg [31:0] cnt;
  always @(posedge I_clk)begin
    if(I_rst) begin
      O_led <= 4'b0;
    end 
    else if (led & O_led != 1'b1)begin
      O_led <= 1'b1;
    end
    else begin
      if (cnt < 1000000) cnt <= cnt + 1'b1;//10000000
      else begin
            cnt <= 1'b0;
            O_led <= 1'b0;
        end
    end
  end

  always @(posedge I_clk)begin
      if(I_rst == 1'b1) begin
        display <=4'h0;
      end 
      else begin
        display <= data;
      end 
    end

endmodule
