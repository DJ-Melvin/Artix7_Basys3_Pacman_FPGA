`timescale 1ns / 1ps
/////////////////////////////////////////////////////////////////
// Module Name: manual_dir_control
/////////////////////////////////////////////////////////////////

module manual_dir_control(
    input clk,
    input [0:89] map,
    input [1:0] scene,
    input [4:0] pac_x,
    input [4:0] pac_y,
    input [4:0] clyde_x,
    input [4:0] clyde_y,
    input [9:0] rec,
    output reg [1:0] pac_dir,
    output reg [1:0] clyde_dir
    );
    
    parameter up = 2'b00;
    parameter down = 2'b01;
    parameter left = 2'b10;
    parameter right = 2'b11;
    
    parameter start_scene = 2'b00;
    parameter play_scene = 2'b01;
    parameter win_scene = 2'b10;
    parameter lose_scene = 2'b11;
    
    
    reg [1:0] next_pac_dir;
    reg [1:0] next_clyde_dir;
    
    always@(posedge clk) begin
        if(scene == start_scene) pac_dir <= up;
        else pac_dir <= next_pac_dir;
        clyde_dir <= next_clyde_dir;
    end

    // pacman or clyde's position can be changed if the direction where pacman or clyde wants to go is legal
    // (not a wall and also not exceeding the boundaries)
    always@(*) begin
        if(scene == lose_scene || scene == win_scene) next_pac_dir = pac_dir;
        else if(rec[9]) next_pac_dir = pac_x > 0 ? (map[pac_x - 1 + pac_y * 18] ? pac_dir: left) : pac_dir;
        else if(rec[8]) next_pac_dir = pac_y < 4 ? (map[pac_x + (pac_y + 1) * 18] ? pac_dir: down) : pac_dir;
        else if(rec[7]) next_pac_dir = pac_y > 0 ? (map[pac_x + (pac_y - 1) * 18] ? pac_dir: up) : pac_dir;
        else if(rec[6]) next_pac_dir = pac_x < 17 ? (map[pac_x + 1 + pac_y * 18] ? pac_dir: right) : pac_dir;
        else next_pac_dir = pac_dir;
    end
    
    always@(*) begin
            if(rec[5]) next_clyde_dir = clyde_y > 0 ? (map[clyde_x + (clyde_y - 1) * 18] ? clyde_dir: up) : clyde_dir;
            else if(rec[4]) next_clyde_dir = clyde_y < 4 ? (map[clyde_x + (clyde_y + 1) * 18] ? clyde_dir: down) : clyde_dir;
            else if(rec[3]) next_clyde_dir = clyde_x > 0 ? (map[clyde_x - 1 + clyde_y * 18] ? clyde_dir: left) : clyde_dir;
            else if(rec[2]) next_clyde_dir = clyde_x < 17 ? (map[clyde_x + 1 + clyde_y * 18] ? clyde_dir: right) : clyde_dir;
            else next_clyde_dir = clyde_dir;
    end
endmodule
