`timescale 1ns / 1ps

module wb(
    input [5:0] I_opcode,
    input [5:0] I_funct,
    input [31:0] I_write_data,
    input [4:0] I_dest_reg,

    output O_reg_write,
    output [31:0] O_write_data,
    output [4:0] O_dest_reg
);
    wire jal;

    assign O_write_data = I_write_data;
    assign O_dest_reg = jal ? 5'd31 : I_dest_reg;

    
    wb_control wb_ctrl_inst(
        .I_opcode(I_opcode),
        .I_funct(I_funct),
        .O_reg_write(O_reg_write),
        .O_jal(jal)
    );
endmodule
