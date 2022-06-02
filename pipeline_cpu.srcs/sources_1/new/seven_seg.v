`timescale 1ns / 1ps

module seven_seg(
    input I_clk,
    input I_rst, 
    input I_write,
    input [31:0] I_write_data,
    output reg [7:0] O_num, 
    output reg [7:0] O_seg_en
    );
    
    parameter    SEG_num0 = 8'b1100_0000,  
                  SEG_num1 = 8'b1111_1001,
                  SEG_num2 = 8'b1010_0100,
                  SEG_num3 = 8'b1011_0000,
                  SEG_num4 = 8'b1001_1001,
                  SEG_num5 = 8'b1001_0010,
                  SEG_num6 = 8'b1000_0010,
                  SEG_num7 = 8'b1111_1000,
                  SEG_num8 = 8'b1000_0000,
                  SEG_num9 = 8'b1001_0000,
                  SEG_num10 = 8'b1000_1000,//a
                  SEG_num11 = 8'b1000_0011,//b
                  SEG_num12 = 8'b1010_0111,//c
                  SEG_num13 = 8'b1010_0001,//d
                  SEG_num14 = 8'b1000_0110,//e
                  SEG_num15 = 8'b1000_1110;//f
    parameter    
                  DUAN_7 = 8'b01111111,
                  DUAN_6 = 8'b10111111,
                  DUAN_5 = 8'b11011111,
                  DUAN_4 = 8'b11101111,
                  DUAN_3 = 8'b11110111,              
                  DUAN_2 = 8'b11111011,
                  DUAN_1 = 8'b11111101,
                  DUAN_0 = 8'b11111110;
                  
    reg [2:0] count = 0;
    integer result;
    always @(posedge I_clk or posedge I_rst) begin
        if (I_rst == 1'b1) result <= 0;
        else if (I_write == 1'b1)
//            if (I_sel == 1'b0) 
            result <= I_write_data;
//            else led_data[23:16] <= I_write_data[7:0];
        else result <= result;
    end
    integer origin;
    integer eight;
    integer seven;
    integer six;
    integer five;
    integer four;
    integer three;
    integer two;
    integer one;
    always @(result) begin
        eight = (result & 32'hf0000000) >> 28;
        seven = (result & 32'h0f000000) >> 24;
        six   = (result & 32'h00f00000) >> 20;
        five  = (result & 32'h000f0000) >> 16;
        four  = (result & 32'h0000f000) >> 12;
        three = (result & 32'h00000f00) >> 8;
        two   = (result & 32'h000000f0) >> 4;
        one   = (result & 32'h0000000f);
    end
    
    
    reg [17:0] divide;
    always @(posedge I_clk) begin
        if(divide == 100000)
            divide <= 0;
        else
            divide <= divide + 1'b1;
    end
    reg clk_2ms = 0;
    always @ (posedge I_clk) begin
        if(divide < 50000)
            clk_2ms <= 0;
        else
            clk_2ms <= 1;
    end
    
    always @ (posedge clk_2ms) begin
            count <= count + 1'b1;    
        end
   
    always @ (posedge clk_2ms) begin
      case(count)
      3'b000: begin
                    O_seg_en <= DUAN_7;
                       case(eight)
                       4'd0: O_num <= SEG_num0;
                       4'd1: O_num <= SEG_num1;
                       4'd2: O_num <= SEG_num2;
                       4'd3: O_num <= SEG_num3;
                       4'd4: O_num <= SEG_num4;
                       4'd5: O_num <= SEG_num5;
                       4'd6: O_num <= SEG_num6;
                       4'd7: O_num <= SEG_num7;
                       4'd8: O_num <= SEG_num8;
                       4'd9: O_num <= SEG_num9;
                       4'd10: O_num <= SEG_num10;
                       4'd11: O_num <= SEG_num11;
                       4'd12: O_num <= SEG_num12;
                       4'd13: O_num <= SEG_num13;
                       4'd14: O_num <= SEG_num14;
                       4'd15: O_num <= SEG_num15;
                       endcase
                      end
      3'b001: begin
              O_seg_en <= DUAN_6;
                 case(seven)
                    4'd0: O_num <= SEG_num0;
                    4'd1: O_num <= SEG_num1;
                    4'd2: O_num <= SEG_num2;
                    4'd3: O_num <= SEG_num3;
                    4'd4: O_num <= SEG_num4;
                    4'd5: O_num <= SEG_num5;
                    4'd6: O_num <= SEG_num6;
                    4'd7: O_num <= SEG_num7;
                    4'd8: O_num <= SEG_num8;
                    4'd9: O_num <= SEG_num9;
                    4'd10: O_num <= SEG_num10;
                    4'd11: O_num <= SEG_num11;
                    4'd12: O_num <= SEG_num12;
                    4'd13: O_num <= SEG_num13;
                    4'd14: O_num <= SEG_num14;
                    4'd15: O_num <= SEG_num15;
                 endcase
                end
        
      3'b010: begin
              O_seg_en <= DUAN_5;
                 case(six)
                    4'd0: O_num <= SEG_num0;
                    4'd1: O_num <= SEG_num1;
                    4'd2: O_num <= SEG_num2;
                    4'd3: O_num <= SEG_num3;
                    4'd4: O_num <= SEG_num4;
                    4'd5: O_num <= SEG_num5;
                    4'd6: O_num <= SEG_num6;
                    4'd7: O_num <= SEG_num7;
                    4'd8: O_num <= SEG_num8;
                    4'd9: O_num <= SEG_num9;
                    4'd10: O_num <= SEG_num10;
                    4'd11: O_num <= SEG_num11;
                    4'd12: O_num <= SEG_num12;
                    4'd13: O_num <= SEG_num13;
                    4'd14: O_num <= SEG_num14;
                    4'd15: O_num <= SEG_num15;
                 endcase
                end
      3'b011: begin
              O_seg_en <= DUAN_4;
                 case(five)
                 4'd0: O_num <= SEG_num0;
                 4'd1: O_num <= SEG_num1;
                 4'd2: O_num <= SEG_num2;
                 4'd3: O_num <= SEG_num3;
                 4'd4: O_num <= SEG_num4;
                 4'd5: O_num <= SEG_num5;
                 4'd6: O_num <= SEG_num6;
                 4'd7: O_num <= SEG_num7;
                 4'd8: O_num <= SEG_num8;
                 4'd9: O_num <= SEG_num9;
                 4'd10: O_num <= SEG_num10;
                 4'd11: O_num <= SEG_num11;
                 4'd12: O_num <= SEG_num12;
                 4'd13: O_num <= SEG_num13;
                 4'd14: O_num <= SEG_num14;
                 4'd15: O_num <= SEG_num15;
                 endcase
                end
      3'b100: begin
              O_seg_en <= DUAN_3;
                 case(four)
                 4'd0: O_num <= SEG_num0;
                 4'd1: O_num <= SEG_num1;
                 4'd2: O_num <= SEG_num2;
                 4'd3: O_num <= SEG_num3;
                 4'd4: O_num <= SEG_num4;
                 4'd5: O_num <= SEG_num5;
                 4'd6: O_num <= SEG_num6;
                 4'd7: O_num <= SEG_num7;
                 4'd8: O_num <= SEG_num8;
                 4'd9: O_num <= SEG_num9;
                 4'd10: O_num <= SEG_num10;
                 4'd11: O_num <= SEG_num11;
                 4'd12: O_num <= SEG_num12;
                 4'd13: O_num <= SEG_num13;
                 4'd14: O_num <= SEG_num14;
                 4'd15: O_num <= SEG_num15;
                 endcase
                end
      3'b101: begin
                        O_seg_en <= DUAN_2;
                           case(three)
                           4'd0: O_num <= SEG_num0;
                           4'd1: O_num <= SEG_num1;
                           4'd2: O_num <= SEG_num2;
                           4'd3: O_num <= SEG_num3;
                           4'd4: O_num <= SEG_num4;
                           4'd5: O_num <= SEG_num5;
                           4'd6: O_num <= SEG_num6;
                           4'd7: O_num <= SEG_num7;
                           4'd8: O_num <= SEG_num8;
                           4'd9: O_num <= SEG_num9;
                           4'd10: O_num <= SEG_num10;
                           4'd11: O_num <= SEG_num11;
                           4'd12: O_num <= SEG_num12;
                           4'd13: O_num <= SEG_num13;
                           4'd14: O_num <= SEG_num14;
                           4'd15: O_num <= SEG_num15;
                           endcase
                          end
      3'b110: begin
                    O_seg_en <= DUAN_1;
                        case(two)
                            4'd0: O_num <= SEG_num0;
                            4'd1: O_num <= SEG_num1;
                            4'd2: O_num <= SEG_num2;
                            4'd3: O_num <= SEG_num3;
                            4'd4: O_num <= SEG_num4;
                            4'd5: O_num <= SEG_num5;
                            4'd6: O_num <= SEG_num6;
                            4'd7: O_num <= SEG_num7;
                            4'd8: O_num <= SEG_num8;
                            4'd9: O_num <= SEG_num9;
                            4'd10: O_num <= SEG_num10;
                            4'd11: O_num <= SEG_num11;
                            4'd12: O_num <= SEG_num12;
                            4'd13: O_num <= SEG_num13;
                            4'd14: O_num <= SEG_num14;
                            4'd15: O_num <= SEG_num15;
                        endcase
                    end

      3'b111: begin
                    O_seg_en <= DUAN_0;
                        case(one)
                            4'd0: O_num <= SEG_num0;
                            4'd1: O_num <= SEG_num1;
                            4'd2: O_num <= SEG_num2;
                            4'd3: O_num <= SEG_num3;
                            4'd4: O_num <= SEG_num4;
                            4'd5: O_num <= SEG_num5;
                            4'd6: O_num <= SEG_num6;
                            4'd7: O_num <= SEG_num7;
                            4'd8: O_num <= SEG_num8;
                            4'd9: O_num <= SEG_num9;
                            4'd10: O_num <= SEG_num10;
                            4'd11: O_num <= SEG_num11;
                            4'd12: O_num <= SEG_num12;
                            4'd13: O_num <= SEG_num13;
                            4'd14: O_num <= SEG_num14;
                            4'd15: O_num <= SEG_num15;
                        endcase
                    end
      default:begin
            O_seg_en <= O_seg_en;
            O_num <= O_num;
            end 
      endcase
     
    end
endmodule
