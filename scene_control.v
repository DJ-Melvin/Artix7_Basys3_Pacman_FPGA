`timescale 1ns / 1ps
/////////////////////////////////////////////////////////////////
// Module Name: scene_control
/////////////////////////////////////////////////////////////////

module scene_control(
    input clk,
    input [9:0] pac_x,
    input [9:0] pac_y,
    input [9:0] blinky_x,
    input [9:0] blinky_y,
    input [9:0] clyde_x,
    input [9:0] clyde_y,
    input enter,
    input [2:0] power_cnt,
    input [5:0] dot_cnt,
    output reg [1:0] scene
    );
    
    parameter start_scene = 2'b00;
    parameter play_scene = 2'b01;
    parameter win_scene = 2'b10;
    parameter lose_scene = 2'b11;
    
    reg [1:0] next_scene;
    
    always@(posedge clk) begin 
        scene <= next_scene;
    end
    
    // scene change from start to play when enter is pressed
    // in the play scene, when all the dots is eaten by pacman, pacman wins the game,
    // however, before pacman eat all the dots, if he touchs the ghost without power bean's special effect, 
    // pacman loses the game, that is, the ghosts win the game
    // after the game ends, press enter again to go back to the start scene
    always@(*) begin
        case(scene) 
            start_scene: begin
                if(enter) next_scene = play_scene;
                else next_scene = scene;
            end
            play_scene: begin
                if(dot_cnt == 0) next_scene = win_scene;
                else if((pac_x == blinky_x && pac_y == blinky_y) || (pac_x == clyde_x && pac_y == clyde_y) && power_cnt == 0) next_scene = lose_scene;
                else next_scene = scene;
            end
            win_scene: begin
                if(enter) next_scene = start_scene;
                else next_scene = scene;
            end
            lose_scene: begin
                if(enter) next_scene = start_scene;
                else next_scene = scene;                
            end
            default: next_scene = start_scene;
        endcase
    end
endmodule
