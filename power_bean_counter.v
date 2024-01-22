`timescale 1ns / 1ps
/////////////////////////////////////////////////////////////////
// Module Name: power_bean_counter
/////////////////////////////////////////////////////////////////

module power_bean_counter(
    input clk,
    input [26:0] display_cnt,
    input [1:0] scene,
    input power,
    output reg [2:0] power_cnt
    );
    
    // when pacman eats the power bean, power_cnt starts to count in pacman's next 8 moves,
    // that is, after Pac-Man consumes the power bean, the special effect lasts for 8 moves.
    always @(posedge clk) begin
        if(scene == 2'b00) power_cnt <= 3'b000;
        else if(display_cnt[25]) begin
            if(power) power_cnt <= 3'b001;
            else begin
                if(power_cnt == 3'b000) power_cnt <= power_cnt;
                else power_cnt <= power_cnt + 3'b001;
            end
        end
        else begin
            power_cnt <= power_cnt;
        end
    end
endmodule
