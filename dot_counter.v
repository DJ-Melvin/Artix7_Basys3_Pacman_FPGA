`timescale 1ns / 1ps
/////////////////////////////////////////////////////////////////
// Module Name: dot_counter
/////////////////////////////////////////////////////////////////

module dot_counter(
    input clk,
    input [1:0] scene,
    input [26:0] display_cnt,
    input [4:0] pac_x,
    input [4:0] pac_y,
    output reg [5:0] dot_cnt,
    output reg [0:89] dot
    );
    
    parameter start_scene = 2'b00;
    parameter play_scene = 2'b01;
    parameter win_scene = 2'b10;
    parameter lose_scene = 2'b11;
    
    // count the remaining dots on the map
    always@(posedge clk) begin
        if(scene == start_scene) begin // refresh the dot map
            dot <= {18'b111111000000111111,
                   18'b100111000000111001,
                   ~18'b010010000000010010,
                   ~18'b011010111111010110,
                   ~18'b000000000100000000};
            dot_cnt <= 57;
        end
        else if(scene == play_scene && display_cnt[25]) begin
            if(dot[pac_x + pac_y * 18]) begin
                dot[pac_x + pac_y * 18] <= 1'b0;
                dot_cnt <= dot_cnt - 1;
            end
            else begin
                dot[pac_x + pac_y * 18] <= dot[pac_x + pac_y * 18];
                dot_cnt <= dot_cnt;
            end
        end
        else begin
            dot[pac_x + pac_y * 18] <= dot[pac_x + pac_y * 18];
            dot_cnt <= dot_cnt;
        end
    end
endmodule
