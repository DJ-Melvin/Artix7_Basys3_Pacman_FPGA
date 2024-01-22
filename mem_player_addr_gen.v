`timescale 1ns / 1ps
/////////////////////////////////////////////////////////////////
// Module Name: mem_player_addr_gen
/////////////////////////////////////////////////////////////////

module mem_player_addr_gen(
   input [9:0] h_cnt,
   input [9:0] v_cnt,
   input [9:0] x,
   input [9:0] y,
   output [10:0] player_pixel_addr
   );
  
   assign player_pixel_addr = ((h_cnt - x) % 42 + ((v_cnt - y) % 42 )* 42) % 1764;  
   // 42 * 42
    
endmodule