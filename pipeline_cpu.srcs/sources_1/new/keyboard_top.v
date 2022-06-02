`timescale 1ns / 1ps

module keyboard_top(
    input I_clk_25M,
    input I_rst,
    input I_commit,
    input [3:0] I_keyboard_cols,
    output [3:0] O_keyboard_rows,
    output [31:0] O_display,
    output [31:0] O_read_data
    );

    wire [3:0] O_value;
    wire [3:0] onebit_display_keyboard;
    wire [31:0] io_read_data_keyboard;
    wire signal;

    keyboard keyboard_inst(
            .I_clk(I_clk_25M),
            .I_rst(I_rst),
            .display(onebit_display_keyboard),
            .I_cols(I_keyboard_cols),
            .O_signal(signal),
            .O_rows(O_keyboard_rows)
         );
    wire led_wire = signal;
    wire led_anti_shake;
    wire [31:0] io_display_keyboard;
    
    anti_shake_single anti_inst(
        .I_key(led_wire),
        .I_clk(I_clk_25M),
        .I_rst(I_rst),
        .O_key(led_anti_shake)
    );
    
    queue q_inst(
        .I_clk(I_clk_25M),
        .I_rst(I_rst),
        .I_commit(I_commit),
        .next(led_anti_shake),
        .value(onebit_display_keyboard),
        .O_keyboard_value(O_display),
        .O_read_data_value(O_read_data)
    );
endmodule
