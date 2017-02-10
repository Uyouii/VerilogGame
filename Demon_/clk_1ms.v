`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    20:54:53 01/05/2016 
// Design Name: 
// Module Name:    clk_1ms 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: 
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module clk_1ms(
	input clk,
	input reset,
	output clk_1ms
    );
reg[20:0] count;
reg second_m;

initial count <= 0;

	always@(posedge clk)begin
		if(reset || (count == 49999))begin
			count <= 0;
			second_m <= 1;
		end
		else begin
			count <= count + 1;
			second_m <= 0;
			end
		end
assign clk_1ms = second_m;

endmodule
