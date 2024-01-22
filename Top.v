`timescale 1ns / 1ps
/////////////////////////////////////////////////////////////////
// Module Name: TOP
/////////////////////////////////////////////////////////////////

module TOP (
    input rst,
    input clk,
    inout PS2_CLK,
    inout PS2_DATA,
    output [3:0] vgaRed,
    output [3:0] vgaGreen,
    output [3:0] vgaBlue,
    output hsync,
    output vsync,
    output pmod_1, //AIN
    output pmod_2, //GAIN
    output pmod_4, //SHUTDOWN_N
    );

    parameter up = 2'b00;
    parameter down = 2'b01;
    parameter left = 2'b10;
    parameter right = 2'b11;
    
    parameter start_scene = 2'b00;
    parameter play_scene = 2'b01;
    parameter win_scene = 2'b10;
    parameter lose_scene = 2'b11;
    
    wire [26:0] display_cnt;
    wire [4:0] map_pac_x;
    wire [4:0] map_pac_y;
    wire [4:0] map_blinky_x;
    wire [4:0] map_blinky_y;
    wire [4:0] map_clyde_x;
    wire [4:0] map_clyde_y;

    // 0: path
    // 1: wall
    reg [0:89] map = {
        18'b000000100001000000,
        18'b011000110011000110,
        18'b010010000000010010,
        18'b011010111111010110,
        18'b000000000000000000};
    
    wire [0:89] dot; // record the dots' position on the map
    wire [5:0] dot_cnt;
    wire power;
    wire [2:0] power_cnt;
    
    wire [1:0] pac_dir;
    wire [1:0] blinky_dir;
    wire [1:0] clyde_dir;
    wire [1:0] scene = start_scene;
    
    wire [11:0] data;
    wire clk_25MHz;
    wire [9:0] dot_pixel_addr;
    wire [11:0] small_dot_pixel;
    wire [11:0] big_dot_pixel;
    wire [10:0] pac_pixel_addr;
    wire [11:0] pac_right_open_pixel;
    wire [11:0] pac_right_close_pixel;
    wire [11:0] pac_left_open_pixel;
    wire [11:0] pac_left_close_pixel;
    wire [11:0] pac_up_open_pixel;
    wire [11:0] pac_up_close_pixel;
    wire [11:0] pac_down_open_pixel;
    wire [11:0] pac_down_close_pixel;
    wire [10:0] blinky_pixel_addr;
    wire [11:0] blinky_right_pixel;
    wire [11:0] blinky_left_pixel;
    wire [11:0] blinky_up_pixel;
    wire [11:0] blinky_down_pixel;
    wire [11:0] blinky_start_pixel;
    wire [10:0] clyde_pixel_addr;
    wire [11:0] clyde_right_pixel;
    wire [11:0] clyde_left_pixel;
    wire [11:0] clyde_up_pixel;
    wire [11:0] clyde_down_pixel;
    wire [11:0] clyde_start_pixel;
    wire [11:0] ghost_pixel;
    wire [15:0] background_pixel_addr;
    wire [11:0] background_pixel;
    wire [13:0] font_pixel_addr;
    wire [11:0] font_pixel;
    wire valid;
    wire [9:0] h_cnt; //640
    wire [9:0] v_cnt; //480
    wire [9:0] pac_x;
    wire [9:0] pac_y;
    wire [9:0] blinky_x;
    wire [9:0] blinky_y;
    wire [9:0] clyde_x;
    wire [9:0] clyde_y;
    wire clyde_go_home;
    wire blinky_go_home;
    wire [9:0] rec;
    wire space;
    wire enter;

    // the position where pacman, blinky and clyde will show on the screen
    assign pac_x = 43 + map_pac_x * 30;
    assign pac_y = 185 + map_pac_y * 30;
    assign blinky_x = 43 + map_blinky_x * 30;
    assign blinky_y = 185 + map_blinky_y * 30;
    assign clyde_x = 43 + map_clyde_x * 30;
    assign clyde_y = 185 + map_clyde_y * 30;

    // In the next 16 moves after pacman eat the power bean, 
    // if the ghost touch pacman, it will be kick back to its origin position
    assign clyde_go_home = (pac_x == clyde_x && pac_y == clyde_y) && power_cnt > 0;
    assign blinky_go_home = (pac_x == blinky_x && pac_y == blinky_y) && power_cnt > 0;

    // the moment when pacman eat the power bean, power will be set to 1
    assign power = (pac_y == 2 && (pac_x == 2 || pac_x == 15) && dot[pac_x + pac_y * 18]);

    // record whether space is pressed or not
    assign space = rec[1];

    // record whether enter is pressed or not
    assign enter = rec[0];
    
    clock_divisor clk_wiz_0_inst(
        .clk(clk),
        .clk1(clk_25MHz)
    );

    display_counter display_counter_inst(
        .clk(clk),
        .display_cnt(display_cnt)
    );

    // count the remaining dot on the map, 
    // also update the map when the dot or power bean is eaten by pacman
    dot_counter dot_counter_inst(
        .clk(clk),
        .scene(scene),
        .display_cnt(display_cnt),
        .pac_x(map_pac_x),
        .pac_y(map_pac_y),
        .dot_cnt(dot_cnt),
        .dot(dot)
    );

    // after pacman eat the power bean, power_cnt will start to count for 16 moves
    power_bean_counter power_bean_counter_inst(
        .clk(clk),
        .display_cnt(display_cnt),
        .scene(scene),
        .power(power),
        .power_cnt(power_cnt)
    );

    // change the scene in specific condition
    scene_control scene_control_inst(
        .clk(clk),
        .pac_x(pac_x),
        .pac_y(pac_y),
        .blinky_x(blinky_x),
        .blinky_y(blinky_y),
        .clyde_x(clyde_x),
        .clyde_y(clyde_y),
        .enter(enter),
        .power_cnt(power_cnt),
        .dot_cnt(dot_cnt),
        .scene(scene)
    );
    
    // to record if A, S, W, D, 1, 2, 3, 5, enter, space are pressed or not
    keyboard_signal keyboard_signal_inst(
        .PS2_DATA(PS2_DATA),
        .PS2_CLK(PS2_CLK),
        .clk(clk),
        .rec(rec)
    );

    // change pacman or clyde's direction according to the keyboard's signal 
    // also make sure they won't collide with the wall
    manual_dir_control manual_dir_control_inst(
        .clk(clk),
        .map(map),
        .scene(scene),
        .pac_x(map_pac_x),
        .pac_y(map_pac_y),
        .clyde_x(map_clyde_x),
        .clyde_y(map_clyde_y),
        .rec(rec),
        .pac_dir(pac_dir),
        .clyde_dir(clyde_dir)
    );
    
    // get blinky's moving direction by the algorithm
    blinky_dir_control blinky_dir_control_inst(
        .clk(clk),
        .power(power),
        .display_cnt(display_cnt),
        .map(map),
        .pac_x(map_pac_x),
        .pac_y(map_pac_y),
        .blinky_x(map_blinky_x),
        .blinky_y(map_blinky_y),
        .blinky_dir(blinky_dir)
    );
    
    // change pacman's position according to the given direction
    pac_move pac_move_inst(
        .clk(clk),
        .scene(scene),
        .display_cnt(display_cnt),
        .map(map),
        .pac_dir(pac_dir),
        .map_pac_x(map_pac_x),
        .map_pac_y(map_pac_y)
    );
    
    // change clyde's position according to the given direction
    clyde_move clyde_move_inst(
        .clk(clk),
        .scene(scene),
        .display_cnt(display_cnt),
        .map(map),
        .clyde_dir(clyde_dir),
        .clyde_go_home(clyde_go_home),
        .map_clyde_x(map_clyde_x),
        .map_clyde_y(map_clyde_y)
    );
    
    // change blinky's position according to the given direction
    blinky_move blinky_move_inst(
        .clk(clk),
        .scene(scene),
        .display_cnt(display_cnt),
        .map(map),
        .blinky_dir(blinky_dir),
        .blinky_go_home(blinky_go_home),
        .map_blinky_x(map_blinky_x),
        .map_blinky_y(map_blinky_y)
    );

    // generate the background music
    top_music top_music_inst(
        .clk(clk),
        .reset(rst),
        .space(space),
        .pmod_1(pmod_1),
        .pmod_2(pmod_2),
        .pmod_4(pmod_4)
    );

    vga_controller vga_inst(
        .pclk(clk_25MHz),
        .reset(rst),
        .hsync(hsync),
        .vsync(vsync),
        .valid(valid),
        .h_cnt(h_cnt),
        .v_cnt(v_cnt)
    );

    // get the rgb for the pixel we want to display
    pixel_gen pixel_gen_inst(
        .valid(valid),
        .scene(scene),
        .h_cnt(h_cnt),
        .v_cnt(v_cnt),
        .small_dot_pixel(small_dot_pixel),
        .big_dot_pixel(big_dot_pixel),
        .ghost_pixel(ghost_pixel),
        .pac_right_open_pixel(pac_right_open_pixel),
        .pac_right_close_pixel(pac_right_close_pixel),
        .pac_left_open_pixel(pac_left_open_pixel),
        .pac_left_close_pixel(pac_left_close_pixel),
        .pac_up_open_pixel(pac_up_open_pixel),
        .pac_up_close_pixel(pac_up_close_pixel),
        .pac_down_open_pixel(pac_down_open_pixel),
        .pac_down_close_pixel(pac_down_close_pixel),
        .blinky_right_pixel(blinky_right_pixel),
        .blinky_left_pixel(blinky_left_pixel),
        .blinky_up_pixel(blinky_up_pixel),
        .blinky_down_pixel(blinky_down_pixel),
        .blinky_start_pixel(blinky_start_pixel),
        .clyde_right_pixel(clyde_right_pixel),
        .clyde_left_pixel(clyde_left_pixel),
        .clyde_up_pixel(clyde_up_pixel),
        .clyde_down_pixel(clyde_down_pixel),
        .clyde_start_pixel(clyde_start_pixel),
        .background_pixel(background_pixel),
        .font_pixel(font_pixel),
        .pac_x(pac_x),
        .pac_y(pac_y),
        .blinky_x(blinky_x),
        .blinky_y(blinky_y),
        .clyde_x(clyde_x),
        .clyde_y(clyde_y),
        .pac_dir(pac_dir),
        .blinky_dir(blinky_dir),
        .clyde_dir(clyde_dir),
        .display_cnt(display_cnt),
        .power_cnt(power_cnt),
        .dot(dot),
        .vgaRed(vgaRed),
        .vgaGreen(vgaGreen),
        .vgaBlue(vgaBlue)
    );

    // get the pixel address for every picture we want to show on the screen

    mem_font_addr_gen mem_font_addr_gen_inst(
        .h_cnt(h_cnt),
        .v_cnt(v_cnt),
        .font_pixel_addr(font_pixel_addr)
    );
    
    mem_dot_addr_gen mem_dot_addr_gen_inst(
        .h_cnt(h_cnt),
        .v_cnt(v_cnt),
        .dot_pixel_addr(dot_pixel_addr)
    );
    
    mem_player_addr_gen mem_pac_addr_gen_inst(
        .h_cnt(h_cnt),
        .v_cnt(v_cnt),
        .x(pac_x),
        .y(pac_y),
        .player_pixel_addr(pac_pixel_addr)
    );
    
    mem_player_addr_gen mem_blinky_addr_gen_inst(
        .h_cnt(h_cnt),
        .v_cnt(v_cnt),
        .x(blinky_x),
        .y(blinky_y),
        .player_pixel_addr(blinky_pixel_addr)
    );
    
    mem_player_addr_gen mem_clyde_addr_gen_inst(
        .h_cnt(h_cnt),
        .v_cnt(v_cnt),
        .x(clyde_x),
        .y(clyde_y),
        .player_pixel_addr(clyde_pixel_addr)
    );
    
    mem_background_addr_gen mem_background_addr_gen_inst(
        .h_cnt(h_cnt),
        .v_cnt(v_cnt),
        .background_pixel_addr(background_pixel_addr)
    );
    
    // same as the other blk_mem_gen, but due to the limited bram, 
    // we write the font coe file manually
    get_font get_font_inst(
        .addr(font_pixel_addr),
        .color(font_pixel)
    );
    
    // get the rgb of the pictures we want to show on the screen according to the pixel address

    blk_mem_gen_background blk_mem_gen_background_inst(
        .clka(clk_25MHz),
        .wea(0),
        .addra(background_pixel_addr),
        .dina(data[11:0]),
        .douta(background_pixel)
    ); 

    blk_mem_gen_pac_right_open blk_mem_gen_pac_right_open_inst(
        .clka(clk_25MHz),
        .wea(0),
        .addra(pac_pixel_addr),
        .dina(data[11:0]),
        .douta(pac_right_open_pixel)
    ); 
    
    blk_mem_gen_pac_right_close blk_mem_gen_pac_right_close_inst(
        .clka(clk_25MHz),
        .wea(0),
        .addra(pac_pixel_addr),
        .dina(data[11:0]),
        .douta(pac_right_close_pixel)
    ); 

    blk_mem_gen_pac_left_open blk_mem_gen_pac_left_open_inst(
        .clka(clk_25MHz),
        .wea(0),
        .addra(pac_pixel_addr),
        .dina(data[11:0]),
        .douta(pac_left_open_pixel)
    ); 

    blk_mem_gen_pac_left_close blk_mem_gen_pac_left_close_inst(
        .clka(clk_25MHz),
        .wea(0),
        .addra(pac_pixel_addr),
        .dina(data[11:0]),
        .douta(pac_left_close_pixel)
    ); 

    blk_mem_gen_pac_up_open blk_mem_gen_pac_up_open_inst(
        .clka(clk_25MHz),
        .wea(0),
        .addra(pac_pixel_addr),
        .dina(data[11:0]),
        .douta(pac_up_open_pixel)
    ); 
    
    blk_mem_gen_pac_up_close blk_mem_gen_pac_up_close_inst(
        .clka(clk_25MHz),
        .wea(0),
        .addra(pac_pixel_addr),
        .dina(data[11:0]),
        .douta(pac_up_close_pixel)
    ); 
    
    blk_mem_gen_pac_down_open blk_mem_gen_pac_down_open_inst(
        .clka(clk_25MHz),
        .wea(0),
        .addra(pac_pixel_addr),
        .dina(data[11:0]),
        .douta(pac_down_open_pixel)
    ); 
    
    blk_mem_gen_pac_down_close blk_mem_gen_pac_down_close_inst(
        .clka(clk_25MHz),
        .wea(0),
        .addra(pac_pixel_addr),
        .dina(data[11:0]),
        .douta(pac_down_close_pixel)
    ); 
   
    blk_mem_gen_big_dot blk_mem_gen_big_dot_inst(
        .clka(clk_25MHz),
        .wea(0),
        .addra(dot_pixel_addr),
        .dina(data[11:0]),
        .douta(big_dot_pixel)
    ); 
   
    blk_mem_gen_small_dot blk_mem_gen_small_dot_inst(
        .clka(clk_25MHz),
        .wea(0),
        .addra(dot_pixel_addr),
        .dina(data[11:0]),
        .douta(small_dot_pixel)
    );
    
    blk_mem_gen_blinky_left blk_mem_gen_blinky_left_inst(
        .clka(clk_25MHz),
        .wea(0),
        .addra(blinky_pixel_addr),
        .dina(data[11:0]),
        .douta(blinky_left_pixel)
    ); 
    
    blk_mem_gen_blinky_right blk_mem_gen_blinky_right_inst(
        .clka(clk_25MHz),
        .wea(0),
        .addra(blinky_pixel_addr),
        .dina(data[11:0]),
        .douta(blinky_right_pixel)
    ); 
    
    blk_mem_gen_blinky_up blk_mem_gen_blinky_up_inst(
        .clka(clk_25MHz),
        .wea(0),
        .addra(blinky_pixel_addr),
        .dina(data[11:0]),
        .douta(blinky_up_pixel)
    ); 
    
    blk_mem_gen_blinky_down blk_mem_gen_blinky_down_inst(
        .clka(clk_25MHz),
        .wea(0),
        .addra(blinky_pixel_addr),
        .dina(data[11:0]),
        .douta(blinky_down_pixel)
    ); 
    
    blk_mem_gen_blinky_start blk_mem_gen_blinky_start_inst(
        .clka(clk_25MHz),
        .wea(0),
        .addra(blinky_pixel_addr),
        .dina(data[11:0]),
        .douta(blinky_start_pixel)
    ); 
    
    blk_mem_gen_clyde_left blk_mem_gen_clyde_left_inst(
        .clka(clk_25MHz),
        .wea(0),
        .addra(clyde_pixel_addr),
        .dina(data[11:0]),
        .douta(clyde_left_pixel)
    ); 
    
    blk_mem_gen_clyde_right blk_mem_gen_clyde_right_inst(
        .clka(clk_25MHz),
        .wea(0),
        .addra(clyde_pixel_addr),
        .dina(data[11:0]),
        .douta(clyde_right_pixel)
    ); 
    
    blk_mem_gen_clyde_up blk_mem_gen_clyde_up_inst(
        .clka(clk_25MHz),
        .wea(0),
        .addra(clyde_pixel_addr),
        .dina(data[11:0]),
        .douta(clyde_up_pixel)
    ); 
    
    blk_mem_gen_clyde_down blk_mem_gen_clyde_down_inst(
        .clka(clk_25MHz),
        .wea(0),
        .addra(clyde_pixel_addr),
        .dina(data[11:0]),
        .douta(clyde_down_pixel)
    ); 
    
    blk_mem_gen_clyde_start blk_mem_gen_clyde_start_inst(
        .clka(clk_25MHz),
        .wea(0),
        .addra(clyde_pixel_addr),
        .dina(data[11:0]),
        .douta(clyde_start_pixel)
    ); 
    
    blk_mem_gen_ghost blk_mem_gen_ghost_inst(
        .clka(clk_25MHz),
        .wea(0),
        .addra(pac_pixel_addr),
        .dina(data[11:0]),
        .douta(ghost_pixel)
    );

endmodule