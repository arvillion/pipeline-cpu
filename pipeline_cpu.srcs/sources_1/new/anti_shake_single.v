`timescale 1ns / 1ps

module anti_shake_single(
	input I_key,
	input I_clk,
	input I_rst,
	output O_key
    );
	wire key_changed1;
	reg [20:0] count;
	reg t1, t_locked1, t2, t_locked2;
	
	always @(posedge I_clk)
		if(I_rst) t1 <= 0;
		else t1 <= I_key;
		
	always @(posedge I_clk)
		if(I_rst) t_locked1 <= 0;
		else t_locked1 <= t1;	
	
	assign key_changed1 = ~t_locked1 & t1;
	
	always @(posedge I_clk)
		if(I_rst) count <= 0;
		else if(key_changed1) count <= 0;
		else count <= count + 1'b1;
 
	always @(posedge I_clk)
		if(I_rst) t2 <= 0;
		else if(count == 500000)
			t2 <= I_key;	
 
	always @(posedge I_clk)
		if(I_rst) t_locked2 <= 0;
		else t_locked2 <= t2;	
 
	assign O_key = ~t_locked2 & t2;
 
endmodule

