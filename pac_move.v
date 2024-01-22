`timescale 1ns / 1ps
/////////////////////////////////////////////////////////////////
// Module Name: pac_move
/////////////////////////////////////////////////////////////////

module pac_move(
    input clk,
    input [1:0] scene,
    input [26:0] display_cnt,
    input [0:89] map,
    input [1:0] pac_dir,
    output reg [4:0] map_pac_x,
    output reg [4:0] map_pac_y
    );
    
    parameter up = 2'b00;
    parameter down = 2'b01;
    parameter left = 2'b10;
    parameter right = 2'b11;
    
    parameter start_scene = 2'b00;
    parameter play_scene = 2'b01;
    parameter win_scene = 2'b10;
    parameter lose_scene = 2'b11;
    
    // by the given direction, pacman's position can be changed if the position where pacman wants to go is legal
    // (not a wall and also not exceeding the boundaries)
    always@(posedge clk) begin
        if(scene == start_scene) begin
            map_pac_x <= 9;
            map_pac_y <= 4;
        end
        else if(scene == play_scene && display_cnt[25]) begin
            if(pac_dir == left && map_pac_x > 5'd0 && ~map[map_pac_x - 1 + map_pac_y * 18]) begin
                map_pac_x <= map_pac_x - 1;
                map_pac_y <= map_pac_y;
            end
            else if(pac_dir == down && map_pac_y < 5'd4 && ~map[map_pac_x + (map_pac_y + 1) * 18]) begin
                map_pac_x <= map_pac_x;
                map_pac_y <= map_pac_y + 1;
            end
            else if(pac_dir == up && map_pac_y > 5'd0 && ~map[map_pac_x + (map_pac_y - 1) * 18]) begin
                map_pac_x <= map_pac_x;
                map_pac_y <= map_pac_y - 1;
            end
            else if(pac_dir == right && map_pac_x < 5'd17 && ~map[map_pac_x + 1 + map_pac_y * 18]) begin
                map_pac_x <= map_pac_x + 1;
                map_pac_y <= map_pac_y;
            end
            else begin
                map_pac_x <= map_pac_x;
                map_pac_y <= map_pac_y;
            end
        end
        else begin
            map_pac_x <= map_pac_x;
            map_pac_y <= map_pac_y;
        end
    end
endmodule
