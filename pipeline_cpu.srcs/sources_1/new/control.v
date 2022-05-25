`timescale 1ns / 1ps

module wb_control(
    input [5:0] I_opcode,
    input [5:0] I_funct,
    output O_reg_write
);
   instype ity_inst(
        .I_opcode(I_opcode),
        .I_funct(I_funct),
        .O_reg_write(O_reg_write)
    );
endmodule

module mem_control(
    input [5:0] I_opcode,
    input [5:0] I_funct,
    output O_reg_write,
    output O_lw,
    output O_sw
);
   instype ity_inst(
        .I_opcode(I_opcode),
        .I_funct(I_funct),
        .O_lw(O_lw),
        .O_sw(O_sw),
        .O_reg_write(O_reg_write)
    ); 
endmodule

module exe_control(
    input [5:0] I_opcode,
    input [5:0] I_funct,
    output [1:0] O_aluop,
    output O_regdst, // 1表明目的寄存器是rd, 否则目的寄存器是rt
    output O_alusrc, // 1表明第二个操作数是立即数（beq，bne除外）
    output O_sftmd, // 1表明是shift操作
    output O_force_jump, // 1表明是jr jmp jal
    output O_branch,
    output O_nbranch, 
    output O_jal,
    output O_lw,
    output O_i_minus_format,
    output O_reg_write,

    output O_mfhi,
    output O_mthi,
    output O_mflo,
    output O_mtlo,
    output O_mult,
    output O_multu 
);
    wire r_format, i_minus_format, branch, nbranch;
    wire sw, lw, jr, jmp, jal;

    assign O_aluop = {(r_format | i_minus_format), (branch | nbranch)};
    assign O_regdst = r_format;
    assign O_alusrc = i_minus_format | sw | lw;
    assign O_force_jump = jr | jmp | jal;
    assign O_branch = branch;
    assign O_nbranch = nbranch;
    assign O_jal = jal;
    assign O_lw = lw;
    assign O_i_minus_format = i_minus_format;

    instype ity_inst(
        .I_opcode(I_opcode),
        .I_funct(I_funct),
        .O_r_format(r_format),
        .O_i_minus_format(i_minus_format),
        .O_lw(lw),
        .O_sw(sw),
        .O_jr(jr),
        .O_jmp(jmp),
        .O_jal(jal),
        .O_branch(branch),
        .O_nbranch(nbranch),
        .O_sftmd(O_sftmd),
        .O_reg_write(O_reg_write),

        .O_mfhi(O_mfhi),
        .O_mthi(O_mthi),
        .O_mflo(O_mflo),
        .O_mtlo(O_mtlo),
        .O_mult(O_mult),
        .O_multu(O_multu)
    );
endmodule

module id_control(
    input [5:0] I_opcode,
    input [5:0] I_funct,
    output O_read_rs,
    output O_read_rt,
    output O_should_signed_ext,
    output O_jr
);
    // signed extended for beq, bne, lw, sw, addi, slti,
    assign O_should_signed_ext = (
        I_opcode == 6'b00_0100 ||
        I_opcode == 6'b00_0101 ||
        I_opcode == 6'b10_0011 ||
        I_opcode == 6'b10_1011 ||
        I_opcode == 6'b00_1000 ||
        I_opcode == 6'b00_1010
    ) ? 1 : 0;

    wire r_format, i_minus_format, branch, nbranch;
    wire sw, lw, jr, jmp, jal, sftmd;

    assign O_jr = jr;

    wire mfhi, mthi, mflo, mtlo, mult, multu;

    instype ity_inst(
        .I_opcode(I_opcode),
        .I_funct(I_funct),
        .O_r_format(r_format),
        .O_i_minus_format(i_minus_format),
        .O_lw(lw),
        .O_sw(sw),
        .O_jr(jr),
        .O_jmp(jmp),
        .O_jal(jal),
        .O_branch(branch),
        .O_nbranch(nbranch),
        .O_sftmd(sftmd),
        
        .O_mfhi(mfhi),
        .O_mthi(mthi),
        .O_mflo(mflo),
        .O_mtlo(mtlo),
        .O_mult(mult),
        .O_multu(multu)
    );

    // don't read rs: sll srl sra lui jump jal
    //                mfhi mflo
    assign O_read_rs = (
        (r_format && (I_funct == 6'b00_0000 || I_funct == 6'b00_0010 || I_funct == 6'b00_0011)) ||
        (I_opcode == 6'b00_1111) || jmp || jal || mfhi || mflo
    ) ? 0 : 1;

    // don't read rt: jr lw i_minus_format jump jal
    //                mfhi mthi mflo mtlo
    assign O_read_rt = (
        jr || lw || i_minus_format || jmp || jal || mfhi || mthi || mflo || mtlo
    ) ? 0 : 1;
endmodule

module instype (
    input [5:0] I_opcode,
    input [5:0] I_funct,
    output O_r_format,
    output O_i_minus_format,
    output O_lw,
    output O_sw,
    output O_jr,
    output O_jmp,
    output O_jal,
    output O_branch,
    output O_nbranch,
    output O_sftmd,
    output O_reg_write, // 1表名指令需要写寄存器

    output O_mfhi,
    output O_mthi,
    output O_mflo,
    output O_mtlo,
    output O_mult,
    output O_multu
);
    assign O_r_format = (I_opcode == 6'b0) ? 1'b1 : 1'b0;
    assign O_i_minus_format = (I_opcode[5:3] == 3'b001) ? 1'b1 : 1'b0;
    assign O_lw = (I_opcode == 6'b100011) ? 1'b1 : 1'b0;
    assign O_sw = (I_opcode == 6'b101011) ? 1'b1 : 1'b0;
    assign O_jr = O_r_format & (I_funct == 6'b00_1000 ? 1'b1 : 1'b0);
    assign O_jmp = (I_opcode == 6'b00_0010) ? 1'b1 : 1'b0;
    assign O_jal = (I_opcode == 6'b00_0011) ? 1'b1 : 1'b0;
    assign O_branch = (I_opcode == 6'b00_0100) ? 1'b1 : 1'b0;
    assign O_nbranch = (I_opcode == 6'b00_0101) ? 1'b1 : 1'b0;
    assign O_sftmd = O_r_format & (I_funct[5:3] == 3'b0 ? 1'b1 : 1'b0);
    
    // R type(exclude jr, mthi, mtlo, mult, multu), I minus format jal
    assign O_reg_write = (O_r_format | O_lw | O_jal | O_i_minus_format) & 
                        ~(O_jr | O_mthi | O_mtlo | O_mult | O_multu);

    assign O_mfhi = O_r_format & (I_funct == 6'b01_0000);
    assign O_mthi = O_r_format & (I_funct == 6'b01_0001);
    assign O_mflo = O_r_format & (I_funct == 6'b01_0010);
    assign O_mtlo = O_r_format & (I_funct == 6'b01_0011);
    assign O_mult = O_r_format & (I_funct == 6'b01_1000);
    assign O_multu = O_r_format & (I_funct == 6'b01_1001);


endmodule