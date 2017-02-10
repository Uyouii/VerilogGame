`timescale 1ns / 1ps

// Module Name:    TOP 
// Project Name: 	 Demon

//////////////////////////////////////////////////////////////////////////////////


module TOP(
input wire clk,
input wire[3:0]btn,
input wire[7:0]SW,
output wire HS,
output wire VS,
output  red,
output  green,
output  blue
    );
wire video;
wire[9:0]h_count;
wire[9:0]v_count;
wire shut,clr,jump,reset;
wire clk_1ms,clk_10ms,clk_5ms,clk_150ms,clk_100ms,clk_20ms,clk_01ms;
assign clr = btn[0];	 
assign reset = btn[1];
assign jump = btn[3];
assign shut = SW[0];


VGA_640x480 U1(.clk(clk),.RESET(clr),.HS(HS),.VS(VS),.pixel(h_count),.line(v_count),.video(video));
draw_demon1 U2(.clk(clk),.video(video),.h_count(h_count),.v_count(v_count),.red(red),.green(green),.blue(blue),.jump(jump),.clk_5ms(clk_5ms),.clk_100ms(clk_100ms),.clk_10ms(clk_10ms),.shut(shut),.clr(clr),.reset(reset),.clk_1ms(clk_1ms),.clk_01ms(clk_01ms));
clk_1ms     U3(.clk(clk),.reset(clr),.clk_1ms(clk_1ms));
clk_5ms     U4(.clk_1ms(clk_1ms),.reset(clr),.clk_5ms(clk_5ms));
clk_100ms   U5(.clk_1ms(clk_1ms),.reset(clr),.clk_100ms(clk_100ms));
clk_10ms   U6(.clk_1ms(clk_1ms),.reset(clr),.clk_10ms(clk_10ms));
clk_01ms   U7(.clk(clk),.reset(clr),.clk_01ms(clk_01ms));


endmodule
