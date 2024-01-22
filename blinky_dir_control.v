`timescale 1ns / 1ps
/////////////////////////////////////////////////////////////////
// Module Name: blinky_dir_control
/////////////////////////////////////////////////////////////////

module blinky_dir_control(
    input clk,
    input power,
    input [26:0] display_cnt,
    input [0:89] map,
    input [4:0] pac_x,
    input [4:0] pac_y,
    input [4:0] blinky_x,
    input [4:0] blinky_y,
    output reg [1:0] blinky_dir
);
    
    parameter CHASE = 2'b00;
    parameter HIDE  = 2'b01;
    parameter KEEP_CHASING = 2'b10;

    parameter up = 2'b00;
    parameter down = 2'b01;
    parameter left = 2'b10;
    parameter right = 2'b11;

    reg [1:0] blinky_state = CHASE;
    reg [1:0] next_blinky_state;
    reg [3:0] keep_chasing_cnt;

    wire [1:0] blinky_chase_dir, blinky_flee_dir;
    // reg [1:0] blinky_prev_dir;

    wire [4:0] abs_x_dis = (blinky_x - pac_x) > 0 ? (blinky_x - pac_x) : (pac_x - blinky_x);
    wire [4:0] abs_y_dis = (blinky_y - pac_y) > 0 ? (blinky_y - pac_y) : (pac_y - blinky_y);
    
    always@(posedge clk) begin
        if(power) blinky_state <= HIDE; // pacman eat the power bean
        else blinky_state <= next_blinky_state;
    end

    // when blinky is close enough to pacman, it will not keep chasing instead hide to her home
    // after she go back to her home, she will keep chasing pacman in the next 16 moves
    // no matter how close the distance between pacman and she.
    always@(posedge clk) begin
        if(display_cnt[25]) begin
            if(blinky_x == 5'd8 && blinky_y == 5'd1 && blinky_state == HIDE) keep_chasing_cnt <= 1;
            else if(keep_chasing_cnt > 0) keep_chasing_cnt <= keep_chasing_cnt + 1;
            else keep_chasing_cnt <= keep_chasing_cnt;
        end
        else keep_chasing_cnt <= keep_chasing_cnt;
    end

    always@(*) begin
        case(blinky_state) 
            CHASE: begin
                if(abs_x_dis + abs_y_dis <= 4) next_blinky_state = HIDE;
                else next_blinky_state = blinky_state;
            end
            HIDE: begin
                if(blinky_x == 5'd8 && blinky_y == 5'd1) next_blinky_state = KEEP_CHASING;
                else next_blinky_state = blinky_state;
            end
            KEEP_CHASING: begin
                if(keep_chasing_cnt == 0) next_blinky_state = CHASE;
                else next_blinky_state = blinky_state;
            end
            default: next_blinky_state = CHASE;
        endcase
    end

    always@(posedge clk) begin
        if(blinky_state == HIDE) begin
            blinky_dir <= blinky_hide_dir;
        end
        else begin
            blinky_dir <= blinky_chase_dir;
        end
    end
    
    // always@(posedge clk) begin
    //     blinky_prev_dir <= blinky_dir;
    // end

    shortest_path blinky_chase(
        .map(map),
        .current_x(blinky_x),
        .current_y(blinky_y),
        .target_x(pac_x),
        .target_y(pac_y),
        // .ghost_prev_dir(blinky_prev_dir),
        .dir(blinky_chase_dir)
    );
    
    shortest_path blinky_hide(
        .map(map),
        .current_x(blinky_x),
        .current_y(blinky_y),
        .target_x(5'd8),
        .target_y(5'd1),
        // .ghost_prev_dir(blinky_prev_dir),
        .dir(blinky_hide_dir)
    );

endmodule