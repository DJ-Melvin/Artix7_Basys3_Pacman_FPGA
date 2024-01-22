`timescale 1ns / 1ps
/////////////////////////////////////////////////////////////////
// Module Name: mem_background_addr_gen
/////////////////////////////////////////////////////////////////

module mem_background_addr_gen(
   input [9:0] h_cnt,
   input [9:0] v_cnt,
   output [15:0] background_pixel_addr
   );
  
   assign background_pixel_addr = ((h_cnt >> 1) + 320 * ((v_cnt - 30) >>1 )) % 54400;
   // 640 * 340 => 320 * 170 
   // form (0, 30) to (639, 369)
    
endmodule
