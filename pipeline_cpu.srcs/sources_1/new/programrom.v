`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2022/05/24 00:02:25
// Design Name: 
// Module Name: programrom
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


module programrom(
    input I_rom_clk, // ROM clock
    input[13:0] I_rom_adr, // From IFetch
    output [31:0] O_Instruction, // To IFetch
    input I_upg_rst, // UPG reset (Active High)
    input I_upg_clk, // UPG clock (10MHz)
    input I_upg_wen, // UPG write enable
    input[13:0] I_upg_adr, // UPG write address
    input[31:0] I_upg_dat, // UPG write data
    input I_upg_done // 1 if program finished
    );
    wire kickOff = I_upg_rst | (~I_upg_rst & I_upg_done );
    
    instructions_ram instr_ram_inst(
        .clka (kickOff ? I_rom_clk : I_upg_clk ),
        .wea (kickOff ? 1'b0 : I_upg_wen ),
        .addra (kickOff ? I_rom_adr : I_upg_adr ),
        .dina (kickOff ? 32'b0 : I_upg_dat ),
        .douta (O_Instruction)
    );
endmodule
