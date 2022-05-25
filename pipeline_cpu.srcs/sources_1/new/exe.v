`timescale 1ns / 1ps

module exe(
    input [31:0] I_rs_data,
    input [31:0] I_rt_data,
    input [31:0] I_imm_extended,
    input [4:0] I_shamt,

    input [5:0] I_opcode,
    input [5:0] I_funct,
    input [31:0] I_pc_plus_4,
    output [31:0] O_addr_result,
    output reg [31:0] O_alu_result,

    input [31:0] I_jump_target, // jump address for j jal jr
    output [31:0] O_corr_target, // correct jump/branch address, only valid when corr_pred = 0
    output O_corr_pred, // 1 indicates that branch prediction is correct

    // possible destination regs
    input [4:0] I_rt,
    input [4:0] I_rd,

    output [4:0] O_dest_reg, // destination reg

    output O_reg_write,
    output O_is_lw,
    output [31:0] O_mem_write_data, // 写入data memory的数据 for sw

    output O_hi_write,
    output O_lo_write,
    output reg [31:0] O_hi_write_data,
    output reg [31:0] O_lo_write_data,

    input [31:0] I_hi_read_data,
    input [31:0] I_lo_read_data

);
    wire [1:0] aluop;
    wire alusrc, sftmd, i_minus_format, force_jump, regdst, jal;
    wire branch, nbranch;

    wire mfhi, mthi, mflo, mtlo, mult, multu;
    wire [63:0] signed_mul_output, unsigned_mul_output;

    exe_control exe_ctrl_inst(
        .I_opcode(I_opcode),
        .I_funct(I_funct),
        .O_aluop(aluop),
        .O_regdst(regdst), // 为1表明目的寄存器是rd, 否则目的寄存器是rt
        .O_alusrc(alusrc), // 表明第二个操作数是立即数（beq，bne除外）
        .O_sftmd(sftmd),
        .O_force_jump(force_jump), // jr jmp jal
        .O_branch(branch),
        .O_nbranch(nbranch),
        .O_jal(jal),
        .O_lw(O_is_lw),
        .O_i_minus_format(i_minus_format),
        .O_reg_write(O_reg_write),

        .O_mfhi(mfhi),
        .O_mthi(mthi),
        .O_mflo(mflo),
        .O_mtlo(mtlo),
        .O_mult(mult),
        .O_multu(multu)
    );

    assign O_dest_reg = regdst == 1'b1 ? I_rd : I_rt;

    wire [31:0] Ainput, Binput;
    wire [2:0] ALU_ctl;
    wire [5:0] Exe_code;
    wire Zero;

    wire [2:0] Sftm; // identify the types of shift instruction, equals to Function_opcode[2:0]
    reg [31:0] Shift_Result; // the result of shift operation
    reg [31:0] ALU_output_mux; // the result of arithmetic or logic calculation

    assign Ainput = I_rs_data;
    assign Binput = (alusrc == 0) ? I_rt_data : I_imm_extended;
    assign ALU_ctl[0] = (Exe_code[0] | Exe_code[3]) & aluop[1];
    assign ALU_ctl[1] = ((!Exe_code[2]) | (!aluop[1]));
    assign ALU_ctl[2] = (Exe_code[1] & aluop[1]) | aluop[0];
    assign Exe_code[5:0] = (i_minus_format == 0) ? I_funct : {3'b000, I_opcode[2:0]};

    assign Sftm = I_funct[2:0];
    assign Zero = (ALU_output_mux == 0) ? 1 : 0;

    // bne beq
    assign O_addr_result = I_pc_plus_4 + {I_imm_extended[29:0], 2'b0};

    // sw
    assign O_mem_write_data = I_rt_data; 

     always @* begin
        // jal
        if (jal) O_alu_result = I_pc_plus_4;
        // mfhi mflo
        else if (mfhi) O_alu_result = I_hi_read_data;
        else if (mflo) O_alu_result = I_lo_read_data;
        // slt, slti
        else if (Exe_code[3:0] == 4'b1010 || (Exe_code[3:0] == 4'b0010 && i_minus_format)) 
            O_alu_result = ($signed(Ainput) < $signed(Binput)) ? 1 : 0;
        // sltu, sltiu
        else if (Exe_code[3:0] == 4'b1011 || (Exe_code[3:0] == 4'b0011 && i_minus_format)) 
            O_alu_result = (Ainput < Binput) ? 1 : 0;
        // lui
        else if((ALU_ctl == 3'b101) && (i_minus_format == 1)) 
            O_alu_result = {Binput[15:0], 16'b0};
        // shift operations
        else if (sftmd == 1) O_alu_result = Shift_Result;
        // others
        else O_alu_result = ALU_output_mux;
    end

    always @(*) begin
        case (ALU_ctl)
            3'b000: ALU_output_mux = Ainput & Binput; // and, andi
            3'b001: ALU_output_mux = Ainput | Binput; // or, ori
            3'b010: ALU_output_mux = $signed(Ainput) + $signed(Binput); // add, addi
            3'b011: ALU_output_mux = Ainput + Binput; // addu, addiu
            3'b100: ALU_output_mux = Ainput ^ Binput; // xor, xori
            3'b101: ALU_output_mux = ~(Ainput | Binput); // nor
            3'b110: ALU_output_mux = $signed(Ainput) - $signed(Binput); // sub
            3'b111: ALU_output_mux = Ainput - Binput; // subu
            default: ALU_output_mux = 32'b0;
        endcase
    end
    always @* begin
        if (sftmd) 
            case (Sftm[2:0])
                3'b000: Shift_Result = Binput << I_shamt; // sll
                3'b010: Shift_Result = Binput >> I_shamt; // srl
                3'b100: Shift_Result = Binput << Ainput; // sllv
                3'b110: Shift_Result = Binput >> Ainput; // srlv
                3'b011: Shift_Result = $signed(Binput) >>> I_shamt; // sra
                3'b111: Shift_Result = $signed(Binput) >>> Ainput; // srav
                default: Shift_Result = Binput;
            endcase
        else
            Shift_Result = Binput;
    end

    assign O_corr_pred = (force_jump == 1'b1 || (branch == 1'b1 && Zero == 1'b1) || (nbranch == 1'b1 && Zero == 1'b0)) ? 0 : 1;
    assign O_corr_target = (branch == 1'b1 || nbranch == 1'b1) ? O_addr_result : I_jump_target;

    assign O_hi_write = mthi || mult || multu;
    assign O_lo_write = mtlo || mult || multu;

    signed_multiplier s_mul_inst(
        .A(I_rs_data),
        .B(I_rt_data),
        .P(signed_mul_output)
    );
    unsigned_multiplier u_mul_inst(
        .A(I_rs_data),
        .B(I_rt_data),
        .P(unsigned_mul_output)
    );
    
    always @(*) begin
        if (mthi)       O_hi_write_data = I_rs_data;
        else if (mult)  O_hi_write_data = signed_mul_output[63:32];
        else if (multu) O_hi_write_data = unsigned_mul_output[63:32];
    end

    always @(*) begin
        if (mtlo)       O_lo_write_data = I_rs_data;
        else if (mult)  O_lo_write_data = signed_mul_output[31:0];
        else if (multu) O_lo_write_data = unsigned_mul_output[31:0];
    end

endmodule
