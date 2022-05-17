`timescale 1ns / 1ps

module decoder(
    input [31:0] I_instruction, // 指令内容
    
    // forward
    input I_rs_can_forward,
    input I_rt_can_forward,
    input I_rs_should_stall,
    input I_rt_should_stall,
    input [31:0] I_rs_forward_data, // forward过来的data
    input [31:0] I_rt_forward_data, // forward过来的data

    // rs, rt当前的内容
    input [31:0] I_rs_data,
    input [31:0] I_rt_data,

    output [31:0] O_imm_extended, // 立即数拓展

    // correct content in rs and rt register,
    // either forwarded or normally read
    output [31:0] O_rs_data,
    output [31:0] O_rt_data,
    
    input [31:0] I_pc_plus_4,
    output [31:0] O_pc_plus_4,

    // extracted from the instruction
    output [4:0] O_rs,
    output [4:0] O_rt,
    output [4:0] O_rd,
    output [4:0] O_shamt, // shift位数
    output [5:0] O_opcode,
    output [5:0] O_funct,

    output O_should_stall, // determines whether the pipeline should stall
    
    output [31:0] O_jump_target // jump address for j, jal and jr
);


    wire [15:0] imm; // the immediate extracted from the instruction
    assign O_opcode = I_instruction[31:26];
    assign O_funct = I_instruction[5:0];
    assign O_rs = I_instruction[25:21];
    assign O_rt = I_instruction[20:16];
    assign O_rd = I_instruction[15:11];
    assign O_shamt = I_instruction[10:6];
    assign imm = I_instruction[15:0];

    assign O_pc_plus_4 = I_pc_plus_4;

    wire jr, read_rs, read_rt, should_signed_ext;

    assign O_imm_extended = should_signed_ext ? {{16{imm[15]}}, imm} : {{16{1'b0}}, imm};
    assign O_jump_target = jr ? O_rs_data : {I_pc_plus_4[31:28], I_instruction[25:0], 2'b0};

    assign O_should_stall = (read_rs & I_rs_should_stall) &&
                            (read_rt & I_rt_should_stall);

    assign O_rs_data = I_rs_can_forward ? I_rs_forward_data : I_rs_data;
    assign O_rt_data = I_rt_can_forward ? I_rt_forward_data : I_rt_data;

    id_control id_ctrl_inst(
        .I_opcode(O_opcode),
        .I_funct(O_funct),
        .O_read_rs(read_rs),
        .O_read_rt(read_rt),
        .O_should_signed_ext(should_signed_ext),
        .O_jr(jr)
    );

endmodule
