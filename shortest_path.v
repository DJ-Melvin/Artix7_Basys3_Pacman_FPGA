`timescale 1ns / 1ps
/////////////////////////////////////////////////////////////////
// Module Name: shortest_path
/////////////////////////////////////////////////////////////////

module shortest_path(
    input [0:89] map,
    input [4:0] current_x,
    input [4:0] current_y,
    input [4:0] target_x,
    input [4:0] target_y,
    output reg [1:0] dir
    );

    parameter up = 2'b00;
    parameter down = 2'b01;
    parameter left = 2'b10;
    parameter right = 2'b11;

    wire [4:0] abs_x_dis = (blinky_x - pac_x) > 0 ? (blinky_x - pac_x) : (pac_x - blinky_x);
    wire [4:0] abs_y_dis = (blinky_y - pac_y) > 0 ? (blinky_y - pac_y) : (pac_y - blinky_y);
    wire [4:0] abs_x_dis_right = (current_x - target_x + 1) > 0 ? (current_x - target_x + 1) : (target_x - current_x - 1);
    wire [4:0] abs_x_dis_left = (current_x - target_x - 1) > 0 ? (current_x - target_x - 1) : (target_x - current_x + 1);
    wire [4:0] abs_y_dis_up = (current_y - target_y + 1) > 0 ? (current_y - target_y + 1) : (target_y - current_y - 1);
    wire [4:0] abs_y_dis_down = (current_y - target_y - 1) > 0 ? (current_y - target_y - 1) : (target_y - current_y - 1);

    reg [4:0] min_dist;

    // find the direction which have the shortest distance between blinky and pacman
    always@(*) begin
        min_dist = 5'b11111;
        // down
        if(current_y + 1 <= 5'd4 && map[current_x + current_y * 18 + 18] != 1 && min_dist > abs_x_dis + abs_y_dis_down) begin
            min_dist = abs_x_dis + abs_y_dis_down;
            dir = down;
        end
        // up
        if(current_y - 1 >= 5'd0 && map[current_x + current_y * 18 - 18] != 1 && min_dist > abs_x_dis + abs_y_dis_up) begin
            min_dist = abs_x_dis + abs_y_dis_up;
            dir = up;
        end
        // right
        if(current_x + 1 <= 5'd17 && map[current_x + current_y * 18 + 1] != 1 && min_dist > abs_x_dis_right + abs_y_dis) begin
            min_dist = abs_x_dis_right + abs_y_dis;
            dir = right;
        end
        // left
        if(current_x - 1 >= 5'd0 && map[current_x + current_y * 18 - 1] != 1 && min_dist > abs_x_dis_left + abs_y_dis) begin
            min_dist = abs_x_dis_left + abs_y_dis;
            dir = left;
        end
        
    end
endmodule