`timescale 1ns / 1ps
/////////////////////////////////////////////////////////////////
// Module Name: keyboard_signal
/////////////////////////////////////////////////////////////////

module keyboard_signal(
    inout wire PS2_DATA,
    inout wire PS2_CLK,
    input wire clk,
    output wire [9:0] rec
    );

    parameter [8:0] KEY_CODES_A = 9'b0_0001_1100; // A => 1C
    parameter [8:0] KEY_CODES_S = 9'b0_0001_1011; // S => 1B
    parameter [8:0] KEY_CODES_W = 9'b0_0001_1101; // W => 1D
    parameter [8:0] KEY_CODES_D = 9'b0_0010_0011; // D => 23
    parameter [8:0] KEY_CODES_UP = 9'b0_0111_0011; // UP => 73
    parameter [8:0] KEY_CODES_DOWN = 9'b0_0111_0010; // DOWN => 72
    parameter [8:0] KEY_CODES_LEFT = 9'b0_0110_1001; // LEFT => 69
    parameter [8:0] KEY_CODES_RIGHT = 9'b0_0111_1010; // RIGHT => 7A
    parameter [8:0] KEY_CODES_SPACE = 9'b0_0010_1001; // SPACE=> 29
    parameter [8:0] KEY_CODES_ENTER = 9'b0_0101_1010; // left_enter => 5A
    
    reg [9:0] last_key;
    wire [511:0] key_down;
    wire [8:0] last_change;
    wire been_ready;

    keyboard_decoder key_de (
        .key_down(key_down),
        .last_change(last_change),
        .key_valid(been_ready),
        .PS2_DATA(PS2_DATA),
        .PS2_CLK(PS2_CLK),
        .rst(1'b0),
        .clk(clk)
    );
    
    // Set corresponding flags in the 'rec' array to 1 if the keys A, S, W, D, 5, 2, 1, 3, SPACE, ENTER are pressed.
    // Indices: 9 for A, 8 for S, 7 for W, 6 for D, 5 for 5 key, 4 for 2 key, 3 for 1 key, 2 for 3 key, 1 for SPACE, 0 for ENTER.
    // For example, if the A key is pressed, rec[9] will be set to 1.
    assign rec = {key_down[KEY_CODES_A], key_down[KEY_CODES_S], key_down[KEY_CODES_W], key_down[KEY_CODES_D], key_down[KEY_CODES_UP], 
    key_down[KEY_CODES_DOWN], key_down[KEY_CODES_LEFT], key_down[KEY_CODES_RIGHT], been_ready && key_down[KEY_CODES_SPACE], been_ready && key_down[KEY_CODES_ENTER]};
endmodule
