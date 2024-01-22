`timescale 1ns / 1ps
/////////////////////////////////////////////////////////////////
// Module Name: clyde_move
/////////////////////////////////////////////////////////////////

module clyde_move(
    input clk,
    input [1:0] scene,
    input [26:0] display_cnt,
    input [0:89] map,
    input [1:0] clyde_dir,
    input clyde_go_home,
    output reg [4:0] map_clyde_x,
    output reg [4:0] map_clyde_y
    );
    
    parameter up = 2'b00;
    parameter down = 2'b01;
    parameter left = 2'b10;
    parameter right = 2'b11;
    
    parameter start_scene = 2'b00;
    parameter play_scene = 2'b01;
    parameter win_scene = 2'b10;
    parameter lose_scene = 2'b11;
    
    // by the given direction, clyde's position can be changed if the position where clyde wants to go is legal
    // (not a wall and also not exceeding the boundaries)
    always@(posedge clk) begin
        if(scene == start_scene) begin
            map_clyde_x <= 10;
            map_clyde_y <= 0;
        end
        else if(clyde_go_home) begin
            map_clyde_x <= 10;
            map_clyde_y <= 0;
        end
        else if(scene == play_scene && display_cnt[25]) begin
            if(clyde_dir == left && map_clyde_x > 5'd0 && ~map[map_clyde_x - 1 + map_clyde_y * 18]) begin
                map_clyde_x <= map_clyde_x - 1;
                map_clyde_y <= map_clyde_y;
            end
            else if(clyde_dir == down && map_clyde_y < 5'd4 && ~map[map_clyde_x + (map_clyde_y + 1) * 18]) begin
                map_clyde_x <= map_clyde_x;
                map_clyde_y <= map_clyde_y + 1;
            end
            else if(clyde_dir == up && map_clyde_y > 5'd0 && ~map[map_clyde_x + (map_clyde_y - 1) * 18]) begin
                map_clyde_x <= map_clyde_x;
                map_clyde_y <= map_clyde_y - 1;
            end
            else if(clyde_dir == right && map_clyde_x < 5'd17 && ~map[map_clyde_x + 1 + map_clyde_y * 18]) begin
                map_clyde_x <= map_clyde_x + 1;
                map_clyde_y <= map_clyde_y;
            end
            else begin
                map_clyde_x <= map_clyde_x;
                map_clyde_y <= map_clyde_y;
            end
        end
        else begin
            map_clyde_x <= map_clyde_x;
            map_clyde_y <= map_clyde_y;
        end
    end
endmodule
