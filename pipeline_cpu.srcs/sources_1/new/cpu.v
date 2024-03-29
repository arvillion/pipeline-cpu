`timescale 1ns / 1ps
module cpu(
    input I_clk_100M,
    input I_rst,
    input [23:0] I_switches,
    
    input I_rx,
    output O_tx,
    input start_pg,
    
    input [3:0] I_keyboard_cols,
    output [3:0] O_keyboard_rows,
    
    output [23:0] O_leds,
    output [7:0] O_seg_en,
    output [7:0] O_num,

    input I_commit,

    output O_hs,
    output O_vs,
    output [11:0] O_rgb444
);  

    wire W_cpu_clk; // 25M
    wire uart_clk; //10M
    wire vga_clk = W_cpu_clk;
    wire clk_100M; // 100M
    
    cpuclk cpuclk_inst(
        .clk_in1(I_clk_100M),
        .clk_out1(W_cpu_clk),
        .clk_out2(uart_clk),
        .clk_out3(clk_100M)
    );

    wire spg_bufg;
    BUFG U1(.I(start_pg), .O(spg_bufg));
    reg upg_rst;
    always @ (posedge clk_100M) begin
       if (spg_bufg) upg_rst = 0;
       if (I_rst) upg_rst = 1;
    end
    wire rst;
    assign rst = I_rst | ~upg_rst;
    reg [31:0] pc;
    wire [31:0] next_pc;

    wire stall, corr_pred;
    wire [31:0] corr_target;

    ifetch ifetch_inst(
        .I_pc(pc),
        .O_next_pc(next_pc)
    );

    always @(negedge W_cpu_clk) begin
        if (rst) pc <= 0;
        else if (stall)      pc <= pc;
        else if (~corr_pred) pc <= corr_target;
        else                 pc <= next_pc;
    end

    wire [31:0] instruction;

    wire O_upg_clk;
    wire O_upg_wen;
    wire O_upg_done;
    wire [14:0] O_upg_adr;
    wire [31:0] O_upg_dat;
    uart_bmpg_0 uart_inst(
        .upg_clk_i(uart_clk),
        .upg_rst_i(upg_rst),
        .upg_rx_i(I_rx),
        .upg_clk_o(O_upg_clk),
        .upg_wen_o(O_upg_wen),
        .upg_adr_o(O_upg_adr),
        .upg_dat_o(O_upg_dat),
        .upg_done_o(O_upg_done),
        .upg_tx_o(O_tx)
    );
    wire ditermine_program = O_upg_wen&(~O_upg_adr[14]);
    programrom programrom_inst(
        .I_rom_clk(W_cpu_clk),
        .I_rom_adr(pc[15:2]),
        .O_Instruction(instruction),
        .I_upg_rst(upg_rst),
        .I_upg_clk(uart_clk),
        .I_upg_wen(ditermine_program),
        .I_upg_adr(O_upg_adr),
        .I_upg_dat(O_upg_dat),
        .I_upg_done(O_upg_done)
    );

    reg [31:0] id_in_instruction; // instruction to decoder

    always @(negedge W_cpu_clk) begin
        if (rst)           id_in_instruction <= 0;
        else if (stall)      id_in_instruction <= id_in_instruction;
        else if (~corr_pred) id_in_instruction <= 0; 
        else                 id_in_instruction <= instruction;
    end

    reg [31:0] id_in_pc_plus_4;
    wire [31:0] id_out_pc_plus_4;
    always @(negedge W_cpu_clk) begin
        if (rst)      id_in_pc_plus_4 <= 0;
        else if (stall) id_in_pc_plus_4 <= id_in_pc_plus_4;
        else            id_in_pc_plus_4 <= pc + 4;
    end

    wire rs_can_forward, rt_can_forward;
    wire rs_should_stall, rt_should_stall;
    wire [31:0] rs_forward_data, rt_forward_data;
    wire [31:0] rs_curr_data, rt_curr_data;

    wire [31:0] id_out_imm_extended;
    wire [31:0] id_out_rs_data, id_out_rt_data; 
    wire [4:0] id_out_rs, id_out_rt, id_out_rd;
    wire [4:0] id_out_shamt;
    wire [31:0] id_out_jump_target;
    wire [5:0] id_out_opcode, id_out_funct;



    decoder dec_inst(
        .I_instruction(id_in_instruction),
        .I_rs_can_forward(rs_can_forward),
        .I_rt_can_forward(rt_can_forward),
        .I_rs_should_stall(rs_should_stall),
        .I_rt_should_stall(rt_should_stall),
        .I_rs_forward_data(rs_forward_data),
        .I_rt_forward_data(rt_forward_data),
        .I_rs_data(rs_curr_data),
        .I_rt_data(rt_curr_data),
        .O_imm_extended(id_out_imm_extended),
        .O_rs_data(id_out_rs_data),
        .O_rt_data(id_out_rt_data),
        .I_pc_plus_4(id_in_pc_plus_4),
        .O_pc_plus_4(id_out_pc_plus_4),
        .O_rs(id_out_rs),
        .O_rt(id_out_rt),
        .O_rd(id_out_rd),
        .O_shamt(id_out_shamt),
        .O_opcode(id_out_opcode),
        .O_funct(id_out_funct),
        .O_should_stall(stall),
        .O_jump_target(id_out_jump_target)
    );

    reg [31:0] exe_in_rs_data, exe_in_rt_data, exe_in_imm_extended;
    reg [4:0] exe_in_shamt;
    reg [5:0] exe_in_opcode, exe_in_funct;
    reg [31:0] exe_in_pc_plus_4;
    reg [31:0] exe_in_jump_target;
    reg [4:0] exe_in_rt, exe_in_rd;

    always @(negedge W_cpu_clk) begin
        if (rst) begin
            exe_in_opcode <= 0;
            exe_in_funct <= 0;
            exe_in_shamt <= 0;
            exe_in_rt <= 0;
            exe_in_rd <= 0;
        end
        else if (stall || ~corr_pred) begin
            exe_in_opcode <= 0;
            exe_in_funct <= 0;
            exe_in_shamt <= 0;
            exe_in_rt <= 0;
            exe_in_rd <= 0;
        end
        else begin
            exe_in_rs_data <= id_out_rs_data;
            exe_in_rt_data <= id_out_rt_data;
            exe_in_imm_extended <= id_out_imm_extended;
            exe_in_shamt <= id_out_shamt;
            exe_in_opcode <= id_out_opcode;
            exe_in_funct <= id_out_funct;
            exe_in_pc_plus_4 <= id_out_pc_plus_4;
            exe_in_jump_target <= id_out_jump_target;
            exe_in_rt <= id_out_rt;
            exe_in_rd <= id_out_rd;
        end
    end

    wire [31:0] exe_out_addr_result, exe_out_alu_result;
    wire [31:0] exe_out_mem_write_data;
    wire [4:0] exe_dest_reg;
    wire exe_reg_write, exe_is_lw;

    wire hi_write, lo_write;
    wire [31:0] hi_write_data, lo_write_data;
    wire [31:0] hi_read_data, lo_read_data;

    exe exe_inst(
        .I_rs_data(exe_in_rs_data),
        .I_rt_data(exe_in_rt_data),
        .I_imm_extended(exe_in_imm_extended),
        .I_shamt(exe_in_shamt),
        .I_opcode(exe_in_opcode),
        .I_funct(exe_in_funct),
        .I_pc_plus_4(exe_in_pc_plus_4),
        .O_addr_result(exe_out_addr_result),
        .O_alu_result(exe_out_alu_result),
        .I_jump_target(exe_in_jump_target),
        .O_corr_target(corr_target), // correct jump/branch address, only valid when corr_pred = 1
        .O_corr_pred(corr_pred), // correct prediction
        .I_rt(exe_in_rt),
        .I_rd(exe_in_rd),
        .O_dest_reg(exe_dest_reg),
        .O_reg_write(exe_reg_write),
        .O_is_lw(exe_is_lw),
        .O_mem_write_data(exe_out_mem_write_data),
        
        .O_hi_write(hi_write),
        .O_lo_write(lo_write),
        .O_hi_write_data(hi_write_data),
        .O_lo_write_data(lo_write_data),

        .I_hi_read_data(hi_read_data),
        .I_lo_read_data(lo_read_data)
    );
    
    hilo hilo_inst(
        .I_clk(W_cpu_clk),
        .I_rst(rst),
        .I_hi_write(hi_write),
        .I_lo_write(lo_write),
        .I_hi_write_data(hi_write_data),
        .I_lo_write_data(lo_write_data),

        .O_hi_read_data(hi_read_data),
        .O_lo_read_data(lo_read_data)
    );

    wire [31:0] mem_out_reg_write_data;
    wire [4:0] mem_dest_reg;
    wire [31:0] write_data;
    wire m_write;
    wire [31:0] m_addr;
    wire io_write;

    wire [31:0] m_read_data;

    reg [31:0] mem_in_addr, mem_in_alu_result;
    reg [4:0] mem_in_dest_reg;
    reg [5:0] mem_in_opcode, mem_in_funct;
    reg [31:0] mem_in_write_data;
    
    always @(negedge W_cpu_clk) begin
        if (rst) begin
            mem_in_opcode <= 0;
            mem_in_funct <= 0;
            mem_in_dest_reg <= 0;
        end
        else begin
            mem_in_addr <= exe_out_alu_result;
            mem_in_alu_result <= exe_out_alu_result;
            mem_in_dest_reg <= exe_dest_reg;
            mem_in_opcode <= exe_in_opcode;
            mem_in_funct <= mem_in_funct;
            mem_in_write_data <= exe_out_mem_write_data;
        end

    end
 

    wire [23:0] switches;
    buffer bf_inst(
        .I_clk(I_clk_100M),
        .I_rst(rst),
        .I_switches(I_switches),
        .I_commit(I_commit),
        .O_switches_value(switches)
    );

    wire [31:0] display, kb_read_data;
    wire [31:0] io_read_data = m_addr[15:12]==4'he ? kb_read_data : {8'b0, switches};

    mem mem_inst(
        .I_addr(mem_in_addr),
        .I_alu_result(mem_in_alu_result),
        .I_m_read_data(m_read_data),
        .I_io_read_data(io_read_data),
        .O_reg_write_data(mem_out_reg_write_data),

        .I_dest_reg(mem_in_dest_reg),
        .O_dest_reg(mem_dest_reg),

        .I_opcode(mem_in_opcode),
        .I_funct(mem_in_funct),

        .I_write_data(mem_in_write_data),
        .O_write_data(write_data),
        .O_m_write(m_write),
        .O_m_addr(m_addr),
        .O_io_write(io_write),
        .O_reg_write(mem_reg_write)
    );

    wire ditermine_dmem = O_upg_wen&O_upg_adr[14];
    wire vga_write = io_write && (mem_in_addr >= 32'hfffff000 && mem_in_addr < 32'hfffff960);
    wire io_except_vga_write = io_write & ~vga_write;

    dmemory dmem_inst(
        .I_clk(W_cpu_clk),
        .I_addr(m_addr),
        .I_write_data(write_data),
        .I_m_write(m_write),
        .O_read_data(m_read_data),
        .I_upg_rst(upg_rst), // UPG reset (Active High)
        .I_upg_clk(uart_clk), // UPG ram_clk_i (10MHz)
        .I_upg_wen(ditermine_dmem), // UPG write enable
        .I_upg_adr(O_upg_adr), // UPG write address
        .I_upg_dat(O_upg_dat), // UPG write data
        .I_upg_done(O_upg_done) // 1 if programming is finished
    );


    keyboard_top kt_inst(
        .I_clk_25M(W_cpu_clk),
        .I_rst(rst),
        .I_commit(I_commit),
        .I_keyboard_cols(I_keyboard_cols),
        .O_keyboard_rows(O_keyboard_rows),
        .O_display(display),
        .O_read_data(kb_read_data)
    );
  
    seven_seg seg_inst(
        .I_clk(clk_100M),
        .I_rst(rst),
        .I_write(io_write),
        .I_write_data(display[31:0]), 
        .O_num(O_num),
        .O_seg_en(O_seg_en)
    );

    led led_inst(
        .I_clk(W_cpu_clk),
        .I_rst(rst),
        .I_write(io_except_vga_write),
        .I_write_data(write_data[23:0]),
        .O_led_data(O_leds)
    );

    wire [9:0] px, py;
    wire [11:0] pixel_data;

    vga vga_inst(
        .I_clk_25M(vga_clk),
        .I_rst_n(~rst),
        .O_rgb444(O_rgb444),
        .O_hs(O_hs),
        .O_vs(O_vs),
        .I_pixel_data(pixel_data),
        .O_pixel_x(px),
        .O_pixel_y(py)
    );

    wire [11:0] vga_ram_read_addr;
    wire [11:0] vga_ram_write_addr = mem_in_addr[11:0] & 12'hfff;
    wire [15:0] vga_ram_read_data;

    text_gen text_gen_inst(
        .I_clk(vga_clk),
        .I_pixel_x(px),
        .I_pixel_y(py),
        .O_pixel_data(pixel_data),

        .O_vga_ram_addr(vga_ram_read_addr),
        .I_vga_ram_data(vga_ram_read_data)
    );

    vga_ram vga_ram_inst(
        .addra(vga_ram_write_addr),
        .clka(vga_clk),
        .dina(write_data[15:0]),
        //.dina(16'h0F45),
        .wea(vga_write),

        .addrb(vga_ram_read_addr),
        .clkb(vga_clk),
        .doutb(vga_ram_read_data)
    );




    wire wb_reg_write;
    wire [31:0] wb_write_data;
    wire [4:0] wb_dest_reg;

    reg [5:0] wb_in_opcode, wb_in_funct;
    reg [31:0] wb_in_write_data;
    reg [4:0] wb_in_dest_reg;

    always @(negedge W_cpu_clk) begin
        if (rst) begin
            wb_in_opcode <= 0;
            wb_in_funct <= 0;
            wb_in_dest_reg <= 0;
            wb_in_write_data <= 0;
        end
        else begin
            wb_in_opcode <= mem_in_opcode;
            wb_in_funct <= mem_in_funct;
            wb_in_dest_reg <= mem_dest_reg;
            wb_in_write_data <= mem_out_reg_write_data;
        end
    end

    wb wb_inst(
        .I_opcode(wb_in_opcode),
        .I_funct(wb_in_funct),
        .I_write_data(wb_in_write_data),
        .I_dest_reg(wb_in_dest_reg),

        .O_reg_write(wb_reg_write),
        .O_write_data(wb_write_data),
        .O_dest_reg(wb_dest_reg)
    );



    forward forward_inst1(
        .I_ex_reg_write(exe_reg_write),
        .I_ex_is_lw(exe_is_lw),
        .I_ex_dest(exe_dest_reg),
        .I_ex_data(exe_out_alu_result),

        .I_mem_reg_write(mem_reg_write),
        .I_mem_dest(mem_dest_reg),
        .I_mem_data(mem_out_reg_write_data),

        .I_wb_reg_write(wb_reg_write),
        .I_wb_dest(wb_dest_reg),
        .I_wb_data(wb_write_data),

        .I_reg_src(id_out_rs),
        .O_can_forward(rs_can_forward),
        .O_should_stall(rs_should_stall),
        .O_forward_data(rs_forward_data)
    );

    forward forward_inst2(
        .I_ex_reg_write(exe_reg_write),
        .I_ex_is_lw(exe_is_lw),
        .I_ex_dest(exe_dest_reg),
        .I_ex_data(exe_out_alu_result),

        .I_mem_reg_write(mem_reg_write),
        .I_mem_dest(mem_dest_reg),
        .I_mem_data(mem_out_reg_write_data),

        .I_wb_reg_write(wb_reg_write),
        .I_wb_dest(wb_dest_reg),
        .I_wb_data(wb_write_data),

        .I_reg_src(id_out_rt),
        .O_can_forward(rt_can_forward),
        .O_should_stall(rt_should_stall),
        .O_forward_data(rt_forward_data)
    );

    regfile rf_inst(
        .I_clk(W_cpu_clk),
        .I_rst(rst),
        .I_read_src1(id_out_rs),
        .I_read_src2(id_out_rt),
        .I_write_dest(wb_dest_reg),
        .I_write_data(wb_write_data),
        .O_read_data1(rs_curr_data),
        .O_read_data2(rt_curr_data),
        .I_reg_write(wb_reg_write)
    );

endmodule
