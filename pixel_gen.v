`timescale 1ns / 1ps
/////////////////////////////////////////////////////////////////
// Module Name: pixel_gen
/////////////////////////////////////////////////////////////////

module pixel_gen(
    input valid,
    input [1:0] scene,
    input [9:0] h_cnt,
    input [9:0] v_cnt,
    input [11:0] small_dot_pixel,
    input [11:0] big_dot_pixel,
    input [11:0] ghost_pixel,
    input [11:0] pac_right_open_pixel,
    input [11:0] pac_right_close_pixel,
    input [11:0] pac_left_open_pixel,
    input [11:0] pac_left_close_pixel,
    input [11:0] pac_up_open_pixel,
    input [11:0] pac_up_close_pixel,
    input [11:0] pac_down_open_pixel,
    input [11:0] pac_down_close_pixel,
    input [11:0] blinky_right_pixel,
    input [11:0] blinky_left_pixel,
    input [11:0] blinky_up_pixel,
    input [11:0] blinky_down_pixel,
    input [11:0] blinky_start_pixel,
    input [11:0] clyde_right_pixel,
    input [11:0] clyde_left_pixel,
    input [11:0] clyde_up_pixel,
    input [11:0] clyde_down_pixel,
    input [11:0] clyde_start_pixel,
    input [11:0] background_pixel,
    input [11:0] font_pixel,
    input [9:0] pac_x,
    input [9:0] pac_y,
    input [9:0] blinky_x,
    input [9:0] blinky_y,
    input [9:0] clyde_x,
    input [9:0] clyde_y,
    input [1:0] pac_dir,
    input [1:0] blinky_dir,
    input [1:0] clyde_dir,
    input [26:0] display_cnt,
    input [2:0] power_cnt,
    input [0:89] dot,
    output [3:0] vgaRed,
    output [3:0] vgaGreen,
    output [3:0] vgaBlue,
    );
    
    parameter up = 2'b00;
    parameter down = 2'b01;
    parameter left = 2'b10;
    parameter right = 2'b11;
    
    parameter start_scene = 2'b00;
    parameter play_scene = 2'b01;
    parameter win_scene = 2'b10;
    parameter lose_scene = 2'b11;

    reg [11:0] get_pixel;

    assign {vgaRed, vgaGreen, vgaBlue} = get_pixel;
    
    // When patterns overlap, the output priority is
    // first display pacman, clyde and blinky,
    // then display the wall, dots and the power_bean
    // finally display the background
    always@(*) begin
        if(valid == 1'b1) begin 
            if(scene == start_scene && h_cnt >= 160 && h_cnt < 480 && v_cnt >= 390 && v_cnt < 440) get_pixel = font_pixel;
            else if(h_cnt >= clyde_x + 8 && h_cnt < clyde_x + 38 && v_cnt >= clyde_y + 6 && v_cnt < clyde_y + 35) begin
                if(scene == lose_scene || scene == win_scene || scene == start_scene) get_pixel = clyde_start_pixel;
                else begin
                    case(clyde_dir)
                        up: get_pixel =  clyde_up_pixel;
                        down: get_pixel = clyde_down_pixel;
                        left: get_pixel = clyde_left_pixel;
                        right: get_pixel = clyde_right_pixel;
                        default: get_pixel = clyde_right_pixel;
                    endcase
                end
            end
            else if(h_cnt >= blinky_x + 6 && h_cnt < blinky_x + 39 && v_cnt >= blinky_y + 6 && v_cnt < blinky_y + 35) begin
                if(scene == start_scene || scene == lose_scene || scene == win_scene) get_pixel = blinky_start_pixel;
                else begin
                    case(blinky_dir)
                        up: get_pixel =  blinky_up_pixel;
                        down: get_pixel = blinky_down_pixel;
                        left: get_pixel = blinky_left_pixel;
                        right: get_pixel = blinky_right_pixel;
                        default: get_pixel = blinky_right_pixel;
                    endcase
                end
            end
            else if(h_cnt >= pac_x + 4 && h_cnt < pac_x + 40 && v_cnt >= pac_y + 4 && v_cnt < pac_y + 38) begin
                if(scene == start_scene) get_pixel = pac_left_open_pixel;
                else if(scene == lose_scene || scene == win_scene) begin
                    case(pac_dir)
                        up: get_pixel = pac_up_close_pixel;
                        down: get_pixel = pac_down_close_pixel;
                        left: get_pixel = pac_left_close_pixel;
                        right: get_pixel = pac_right_close_pixel;
                        default: get_pixel = pac_right_open_pixel;
                    endcase
                end
                else if(power_cnt > 0) get_pixel = ghost_pixel;
                else begin
                    case(pac_dir)
                        up: get_pixel = display_cnt[24] ? pac_up_open_pixel : pac_up_close_pixel;
                        down: get_pixel = display_cnt[24] ? pac_down_open_pixel : pac_down_close_pixel;
                        left: get_pixel = display_cnt[24] ? pac_left_open_pixel : pac_left_close_pixel;
                        right: get_pixel = display_cnt[24] ? pac_right_open_pixel : pac_right_close_pixel;
                        default: get_pixel = pac_right_open_pixel;
                    endcase
                end
            end 
            else if(h_cnt >= 55 && h_cnt < 589 && v_cnt >= 191 && v_cnt < 341 && dot[((h_cnt - 49) / 30) + ((v_cnt - 191) / 30) * 18]) begin 
                if(((h_cnt - 49) / 30) + ((v_cnt - 191) / 30) * 18 == 38 || ((h_cnt - 49) / 30) + ((v_cnt - 191) / 30) * 18 == 51) get_pixel = big_dot_pixel;
                else get_pixel = small_dot_pixel;
            end
            else if(v_cnt >= 30 && v_cnt < 370) get_pixel = background_pixel;
            else get_pixel = 12'h0;
        end
        else get_pixel = 12'h0;
    end
endmodule
