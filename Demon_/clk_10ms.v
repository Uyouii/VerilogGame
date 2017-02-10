`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    21:22:37 01/05/2016 
// Design Name: 
// Module Name:    clk_10ms 
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
module clk_10ms(
	input clk_1ms,
	input reset,
	output clk_10ms
    );
reg[5:0] count;
reg second_m;

initial count <= 0;

	always@(posedge clk_1ms)begin
		if(reset || (count == 10))begin
			count <= 0;
			second_m <= 1;
		end
		else begin
			count <= count + 1;
			second_m <= 0;
			end
		end
assign clk_10ms = second_m;

endmodule
