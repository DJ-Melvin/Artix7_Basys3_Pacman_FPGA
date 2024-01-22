`timescale 1ns / 1ps
/////////////////////////////////////////////////////////////////
// Module Name: top_music
/////////////////////////////////////////////////////////////////

module top_music (
	input clk,
	input reset,
	input space,
	output pmod_1,
	output pmod_2,
	output pmod_4
);
    parameter BEAT_FREQ = 32'd8;	//one beat=0.125sec
    parameter DUTY_BEST = 10'd512;	//duty cycle=50%

    wire [31:0] freq;
    wire [7:0] ibeatNum;
    wire beatFreq;
    wire music;
    
    reg silent;
    
    always@(posedge clk) begin
        if(space) silent <= ~silent;
        else silent <= silent;
    end
    
    assign pmod_1 = silent ? 1'd0 : music;
    assign pmod_2 = 1'd1;	//no gain(6dB)
    assign pmod_4 = 1'd1;	//turn-on

    //Generate beat speed
    PWM_gen btSpeedGen ( .clk(clk), 
                        .reset(reset),
                        .freq(BEAT_FREQ),
                        .duty(DUTY_BEST), 
                        .PWM(beatFreq)
    );  
    //Generate variant freq. of tones
    Music music00 ( .ibeatNum(ibeatNum),
                    .tone(freq)
    );

    // Generate particular freq. signal
    PWM_gen toneGen ( 
                    .clk(clk), 
                    .reset(reset), 
                    .freq(freq),
                    .duty(DUTY_BEST), 
                    .PWM(music)
    );

    PlayerCtrl playerCtrl ( .clk(beatFreq), 
                            .reset(reset), 
                            .ibeat(ibeatNum)
    );
endmodule

module PWM_gen (
    input wire clk,
    input wire reset,
	input [31:0] freq,
    input [9:0] duty,
    output reg PWM
);

    wire [31:0] count_max = 100_000_000 / freq;
    wire [31:0] count_duty = count_max * duty / 1024;
    reg [31:0] count;
        
    always @(posedge clk, posedge reset) begin
        if (reset) begin
            count <= 0;
            PWM <= 0;
        end else if (count < count_max) begin
            count <= count + 1;
            if(count < count_duty)
                PWM <= 1;
            else
                PWM <= 0;
        end else begin
            count <= 0;
            PWM <= 0;
        end
    end

endmodule

module Music (
	input [7:0] ibeatNum,	
	output reg [31:0] tone
);
    parameter C5 = 32'd523;
    parameter C6 = 32'd1047;
    parameter G5 = 32'd784;
    parameter E5 = 32'd659;
    parameter Db5 = 32'd554;
    parameter Db6 = 32'd1109;
    parameter Ab5 = 32'd831;
    parameter F5 = 32'd698;
    parameter A5 = 32'd880;
    parameter A5s = 32'd932;
    parameter B5 = 32'd988;
    always @(*) begin
        case (ibeatNum)		// 1/4 beat
            8'd0 : tone = C5;	
            8'd1 : tone = C6;
            8'd2 : tone = G5;
            8'd3 : tone = E5;
            8'd4 : tone = C6;	
            8'd5 : tone = G5;
            8'd6 : tone = E5;

            8'd7 : tone = Db5;
            8'd8 : tone = Db6;	
            8'd9 : tone = Ab5;
            8'd10 : tone = F5;
            8'd11 : tone = Db6;
            8'd12 : tone = Ab5;
            8'd13 : tone = F5;

            8'd14 : tone = C5;
            8'd15 : tone = C6;
            8'd16 : tone = G5;
            8'd17 : tone = E5;
            8'd18 : tone = C6;
            8'd19 : tone = G5;
            8'd20 : tone = E5;

            8'd21 : tone = E5;
            8'd22 : tone = F5;
            8'd23 : tone = G5;
            8'd24 : tone = G5;
            8'd25 : tone = Ab5;
            8'd26 : tone = A5;
            8'd27 : tone = A5;
            8'd28 : tone = A5s;
            8'd29 : tone = B5;
            8'd30 : tone = C6;
            // repeat
            8'd31 : tone = C5;
            8'd32 : tone = C6;
            8'd33 : tone = G5;
            8'd34 : tone = E5;
            8'd35 : tone = C6;
            8'd36 : tone = G5;
            8'd37 : tone = E5;

            8'd38 : tone = Db5;
            8'd39 : tone = Db6;
            8'd40 : tone = Ab5;
            8'd41 : tone = F5;
            8'd42 : tone = Db6;
            8'd43 : tone = Ab5;
            8'd44 : tone = F5;

            8'd45 : tone = C5;
            8'd46 : tone = C6;
            8'd47 : tone = G5;
            8'd48 : tone = E5;
            8'd49 : tone = C6;
            8'd50 : tone = G5;
            8'd51 : tone = E5;

            8'd52 : tone = E5;
            8'd53 : tone = F5;
            8'd54 : tone = G5;
            8'd55 : tone = G5;
            8'd56 : tone = Ab5;
            8'd57 : tone = A5;
            8'd58 : tone = A5;
            8'd59 : tone = A5s;
            8'd60 : tone = B5;
            8'd61 : tone = C6;

            8'd62 : tone = C5;
            8'd63 : tone = C6;
            8'd64 : tone = G5;
            8'd65 : tone = E5;
            8'd66 : tone = C6; 
            8'd67 : tone = G5;
            8'd68 : tone = E5;

            8'd69 : tone = Db5;
            8'd70 : tone = Db6;
            8'd71 : tone = Ab5;
            8'd72 : tone = F5;
            8'd73 : tone = Db6;
            8'd74 : tone = Ab5;
            8'd75 : tone = F5;

            8'd76 : tone = C5;
            8'd77 : tone = C6;
            8'd78 : tone = G5;
            8'd79 : tone = E5;
            8'd80 : tone = C6;
            8'd81 : tone = G5;
            8'd82 : tone = E5;

            8'd83 : tone = E5;
            8'd84 : tone = F5;
            8'd85 : tone = G5;
            8'd86 : tone = G5;
            8'd87 : tone = Ab5;
            8'd88 : tone = A5;
            8'd89 : tone = A5;
            8'd90 : tone = A5s;
            8'd91 : tone = B5;
            8'd92 : tone = C6;

            8'd93 : tone = C5;
            8'd94 : tone = C6;
            8'd95 : tone = G5;
            8'd96 : tone = E5;
            8'd97 : tone = C6;
            8'd98 : tone = G5;
            8'd99 : tone = E5;

            8'd100 : tone = Db5;
            8'd101 : tone = Db6;
            8'd102 : tone = Ab5;
            8'd103 : tone = F5;
            8'd104 : tone = Db6;
            8'd105 : tone = Ab5;
            8'd106 : tone = F5;

            8'd107 : tone = C5;
            8'd108 : tone = C6;
            8'd109 : tone = G5;
            8'd110 : tone = E5;
            8'd111 : tone = C6;
            8'd112 : tone = G5;
            8'd113 : tone = E5;

            8'd114 : tone = E5;
            8'd115 : tone = F5;
            8'd116 : tone = G5;
            8'd117 : tone = G5;
            8'd118 : tone = Ab5;
            8'd119 : tone = A5;
            8'd120 : tone = A5;
            8'd121 : tone = A5s;
            8'd122 : tone = B5;
            8'd123 : tone = C6;

            8'd124 : tone = C5;
            8'd125 : tone = C6;
            8'd126 : tone = G5;
            8'd127 : tone = E5;
            8'd128 : tone = C6;
            8'd129 : tone = G5;
            8'd130 : tone = E5;

            8'd131 : tone = Db5;
            8'd132 : tone = Db6;
            8'd133 : tone = Ab5;
            8'd134 : tone = F5;
            8'd135 : tone = Db6;
            8'd136 : tone = Ab5;
            8'd137 : tone = F5;
            
            8'd138 : tone = C5;
            8'd139 : tone = C6;
            8'd140 : tone = G5;
            8'd141 : tone = E5;
            8'd142 : tone = C6;
            8'd143 : tone = G5;
            8'd144 : tone = E5;

            8'd145 : tone = E5;
            8'd146 : tone = F5;
            8'd147 : tone = G5;
            8'd148 : tone = G5;
            8'd149 : tone = Ab5;
            8'd150 : tone = A5;
            8'd151 : tone = A5;
            8'd152 : tone = A5s;
            8'd153 : tone = B5;
            8'd154 : tone = C6;

            8'd155 : tone = C5;
            8'd156 : tone = C6;
            8'd157 : tone = G5;
            8'd158 : tone = E5;
            8'd159 : tone = C6;
            8'd160 : tone = G5;
            8'd161 : tone = E5;

            8'd162 : tone = Db5;
            8'd163 : tone = Db6;
            8'd164 : tone = Ab5;
            8'd165 : tone = F5;
            8'd166 : tone = Db6;
            8'd167 : tone = Ab5;
            8'd168 : tone = F5;

            8'd169 : tone = C5;
            8'd170 : tone = C6;
            8'd171 : tone = G5;
            8'd172 : tone = E5;
            8'd173 : tone = C6;
            8'd174 : tone = G5;
            8'd175 : tone = E5;

            8'd176 : tone = E5;
            8'd177 : tone = F5;
            8'd178 : tone = G5;
            8'd179 : tone = G5;
            8'd180 : tone = Ab5;
            8'd181 : tone = A5;
            8'd182 : tone = A5;
            8'd183 : tone = A5s;
            8'd184 : tone = B5;
            8'd185 : tone = C6;

            8'd186 : tone = C5;
            8'd187 : tone = C6;
            8'd188 : tone = G5;
            8'd189 : tone = E5;
            8'd190 : tone = C6;
            8'd191 : tone = G5;
            8'd192 : tone = E5;

            8'd193 : tone = Db5;
            8'd194 : tone = Db6;
            8'd195 : tone = Ab5;
            8'd196 : tone = F5;
            8'd197 : tone = Db6;
            8'd198 : tone = Ab5;
            8'd199 : tone = F5;

            8'd200 : tone = C5;
            8'd201 : tone = C6;
            8'd202 : tone = G5;
            8'd203 : tone = E5;
            8'd204 : tone = C6;
            8'd205 : tone = G5;
            8'd206 : tone = E5;

            8'd207 : tone = E5;
            8'd208 : tone = F5;
            8'd209 : tone = G5;
            8'd210 : tone = G5;
            8'd211 : tone = Ab5;
            8'd212 : tone = A5;
            8'd213 : tone = A5;
            8'd214 : tone = A5s;
            8'd215 : tone = B5;
            8'd216 : tone = C6;

            8'd217 : tone = C5;
            8'd218 : tone = C6;
            8'd219 : tone = G5;
            8'd220 : tone = E5;
            8'd221 : tone = C6;
            8'd222 : tone = G5;
            8'd223 : tone = E5;

            8'd224 : tone = Db5;
            8'd225 : tone = Db6;
            8'd226 : tone = Ab5;
            8'd227 : tone = F5;
            8'd228 : tone = Db6;
            8'd229 : tone = Ab5;
            8'd230 : tone = F5;

            8'd231 : tone = C5;
            8'd232 : tone = C6;
            8'd233 : tone = G5;
            8'd234 : tone = E5;
            8'd235 : tone = C6;
            8'd236 : tone = G5;
            8'd237 : tone = E5;
            
            8'd238 : tone = E5;
            8'd239 : tone = F5;
            8'd240 : tone = G5;
            8'd241 : tone = G5;
            8'd242 : tone = Ab5;
            8'd243 : tone = A5;
            8'd244 : tone = A5;
            8'd245 : tone = A5s;
            8'd246 : tone = B5;
            8'd247 : tone = C6;
            
            8'd248 : tone = C5;
            8'd249 : tone = C6;
            8'd250 : tone = G5;
            8'd251 : tone = E5;
            8'd252 : tone = C6;
            8'd253 : tone = G5;
            8'd254 : tone = E5;

            8'd255 : tone = Db5;
            default : tone = 32'd20000;	//Do-dummy
        endcase
    end
endmodule

module PlayerCtrl (
	input clk,
	input reset,
	output reg [7:0] ibeat
);
    parameter BEATLEAGTH = 63;

    always @(posedge clk, posedge reset) begin
        if (reset)
            ibeat <= 0;
        else if (ibeat < BEATLEAGTH) 
            ibeat <= ibeat + 1;
        else 
            ibeat <= 0;
    end

endmodule