`timescale 1ns / 1ps
/////////////////////////////////////////////////////////////////
// Module Name: mem_dot_addr_gen
/////////////////////////////////////////////////////////////////

module mem_dot_addr_gen(
   input [9:0] h_cnt,
   input [9:0] v_cnt,
   output [9:0] dot_pixel_addr
   );
  
   assign dot_pixel_addr = ((h_cnt - 49) % 30 + ((v_cnt - 191) % 30) * 30) % 900;  
   // 30 * 30
endmodule