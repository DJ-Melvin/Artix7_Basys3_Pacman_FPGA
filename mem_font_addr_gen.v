`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Module Name: mem_font_addr_gen
//////////////////////////////////////////////////////////////////////////////////


module mem_font_addr_gen(
    input [9:0] h_cnt,
    input [9:0] v_cnt,
    output [13:0] font_pixel_addr
    );
    
    assign font_pixel_addr = ((h_cnt - 160) + (v_cnt - 390) * 320) % 16000; 
    // 320 * 50
    // from (160, 390) to (479, 439)
endmodule
