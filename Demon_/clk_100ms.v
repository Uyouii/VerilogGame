`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    19:15:14 01/06/2016 
// Design Name: 
// Module Name:    clk_100ms 
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
module clk_100ms(
   input clk_1ms,
	input reset,
	output clk_100ms
    );
reg[8:0] count;
reg second_m;

initial count <= 0;

	always@(posedge clk_1ms)begin
		if(reset || (count == 100))begin
			count <= 0;
			second_m <= 1;
		end
		else begin
			count <= count + 1;
			second_m <= 0;
			end
		end
assign clk_100ms = second_m;

endmodule

