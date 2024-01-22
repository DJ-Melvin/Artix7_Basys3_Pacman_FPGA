`timescale 1ns / 1ps
/////////////////////////////////////////////////////////////////
// Module Name: clock_divisor
/////////////////////////////////////////////////////////////////

module clock_divisor(clk1, clk);
    input clk;
    output clk1;
    reg [21:0] num;
    wire [21:0] next_num;

    // generate a clk for vga controller and block memory generator
    always @(posedge clk) begin
      num <= next_num;
    end

    assign next_num = num + 1'b1;
    assign clk1 = num[1];
endmodule
