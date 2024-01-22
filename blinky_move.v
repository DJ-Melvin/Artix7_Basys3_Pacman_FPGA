`timescale 1ns / 1ps
/////////////////////////////////////////////////////////////////
// Module Name: blinky_move
/////////////////////////////////////////////////////////////////

module blinky_move(
    input clk,
    input [1:0] scene,
    input [26:0] display_cnt,
    input [0:89] map,
    input [1:0] blinky_dir,
    input blinky_go_home,
    output reg [4:0] map_blinky_x,
    output reg [4:0] map_blinky_y
    );
    
    parameter up = 2'b00;
    parameter down = 2'b01;
    parameter left = 2'b10;
    parameter right = 2'b11;
    
    parameter start_scene = 2'b00;
    parameter play_scene = 2'b01;
    parameter win_scene = 2'b10;
    parameter lose_scene = 2'b11;
    
    // by the given direction, blinky's position can be changed if the position where blinky wants to go is legal
    // (not a wall and also not exceeding the boundaries)
    always@(posedge clk) begin
        if(scene == start_scene) begin
            map_blinky_x <= 7;
            map_blinky_y <= 0;
        end
        else if(blinky_go_home) begin
            map_blinky_x <= 7;
            map_blinky_y <= 0;
        end
        else if(scene == play_scene && display_cnt[25]) begin
            if(blinky_dir == left && map_blinky_x > 5'd0 && ~map[map_blinky_x - 1 + map_blinky_y * 18]) begin
                map_blinky_x <= map_blinky_x - 1;
                map_blinky_y <= map_blinky_y;
            end
            else if(blinky_dir == down && map_blinky_y < 5'd4 && ~map[map_blinky_x + (map_blinky_y + 1) * 18]) begin
                map_blinky_x <= map_blinky_x;
                map_blinky_y <= map_blinky_y + 1;
            end
            else if(blinky_dir == up && map_blinky_y > 5'd0 && ~map[map_blinky_x + (map_blinky_y - 1) * 18]) begin
                map_blinky_x <= map_blinky_x;
                map_blinky_y <= map_blinky_y - 1;
            end
            else if(blinky_dir == right && map_blinky_x < 5'd17 && ~map[map_blinky_x + 1 + map_blinky_y * 18]) begin
                map_blinky_x <= map_blinky_x + 1;
                map_blinky_y <= map_blinky_y;
            end
            else begin
                map_blinky_x <= map_blinky_x;
                map_blinky_y <= map_blinky_y;
            end
        end
        else begin
            map_blinky_x <= map_blinky_x;
            map_blinky_y <= map_blinky_y;
        end
    end
endmodule
