`timescale 1ns / 1ps
/////////////////////////////////////////////////////////////////
// Module Name: display_counter
/////////////////////////////////////////////////////////////////

// with display_cnt, we can record the time for Pacman, Clyde, and Blinky to move to the next position. 
// It also helps us keeps track of whether Pacman's mouth should be open or closed.
module display_counter(
    input clk,
    output reg [26:0] display_cnt
    );
    always@(posedge clk) begin
        if(display_cnt[25]) display_cnt <= 0;
        else display_cnt <= display_cnt + 1;
    end
endmodule
