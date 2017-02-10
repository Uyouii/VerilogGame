`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////

// Create Date:    17:11:22 01/05/2016 
// Design Name: 
// Module Name:    draw_demon1 
// Project Name: 	 Demon
/*

此模块为功能实现的主要模块，实现的功能有：
1. Demon和背景图片的时序显示
2.小恐龙移动时图片的交替控制
3.小恐龙的跳跃和空中速度的改变
4.背景图片和障碍物的移动
5.小恐龙与障碍物的碰撞检测
6.游戏的暂停与重置功能
7.随着时间的增加，障碍物移动速度加快的功能

ps：本模块关于图片的调用和显示均调用ROM实现
*/

//////////////////////////////////////////////////////////////////////////////////
module draw_demon1(
	input clk,				//系统50mhz时钟信号
	input [9:0]h_count,	//对应屏幕显示的横坐标
	input [9:0]v_count,	//对应屏幕显示的纵坐标
	input video,
	input jump,				//小恐龙跳跃操作
	input clr,
	input reset,			//重置操作
	input shut,				//暂停操作
	input clk_1ms, 		//对应时钟模块产生的时钟信号，用来时序控制电路
	input clk_5ms,
	input clk_01ms,
	input clk_100ms,
	input clk_10ms,
	output  reg red,
	output  reg green,
	output  reg blue
    );

reg [10:0]x,y;
reg collision,collision1;				//判断游戏是否结束
parameter x1 = 120,x2 = 180;			//Demon的横坐标
parameter y1 = 270,y2 = 330;			//Demon的初始纵坐标
parameter V0 = 82,delta = 1;			//Demon的初始速度与在空中的加速度
parameter X_over = 120;
parameter Y_over = 130;					//结束图片的横纵坐标
parameter Y_ground1 = 267,Y_ground2 = 310,Y_tree1 = 250,Y_tree2 = 268;//地面与障碍物的纵坐标
integer V,count,diff,count1;			
integer ground,tree1,X_tree1,X_tree2,X_cloud1,X_cloud2,X_cloud3,Y_cloud1,Y_cloud2,Y_cloud3;

reg [10:0] Y, S,high_ground1,high_ground2,x_t1,y_t1,x_c1,x_c2,x_c3,y_c1,y_c2,y_c3,x_t2,y_t2,x_v,y_v;
reg [11:0] addr;
reg high,mode,draw_demon1,draw_demon2,in_ground1,in_ground2,in_tree1,in_tree2,in_cloud,in_cloud2,in_over;//in_cloud3;
wire [0:0] color1;
wire [0:0] color2;
wire [0:0] color_ground1,color_ground2,color_tree1,color_tree2,color_cloud,color_cloud2,color_over;//color_cloud3;
wire [15:0] show_ground1,show_ground2;
reg [14:0]show_over;
reg [15:0] show_tree1,show_tree2;
reg[12:0] show_cloud,show_cloud2;//show_cloud3;
reg clk_game;

initial begin
Y = y1;//Y为恐龙现在的位置
V = 0;
mode = 0;
count = 0;
draw_demon1 = 0;
ground = 0;
X_tree1 = 1200;
X_tree2 = 900;
collision = 0;
collision1 = 0;
Y_cloud1 = 50;X_cloud2 = 500;
Y_cloud1 = 110;X_cloud2 = 100;
diff = 60;
count = 0;
count1 = 0;
end


Demon1    Rom1(.clka(clk),.addra(addr),.douta(color1));						//Demon图片1
Demon2    Rom2(.clka(clk),.addra(addr),.douta(color2));						//Demon图片2，两张图片交替显示，构成动态图
ground 	 Rom3(.clka(clk),.addra(show_ground1),.douta(color_ground1));	//背景地面的显示
trees1 	 Rom5(.clka(clk),.addra(show_tree1),.douta(color_tree1));		//障碍物1显示
clouds 	 Rom6(.clka(clk),.addra(show_cloud),.douta(color_cloud));		//背影云彩的显示
trees2 	 Rom9(.clka(clk),.addra(show_tree2),.douta(color_tree2));		//障碍物2显示
game_over Rom10(.clka(clk),.addra(show_over),.douta(color_over));			//游戏结束图片显示

always@(posedge clk_100ms)begin//mode用来判断小恐龙的两种形态，mode == 1显示图片1；mode == 2显示图片2
	if(shut == 1 || collision1 == 1) //判断游戏是否结束或暂停
		mode = mode;
	else mode = ~mode;
end

always@(posedge clk_01ms)begin//clk_game产生的频率受diff控制，cllk_game控制背景的移动速度
	count = count + 1;
	if(count >= diff)begin
		count  = 0;
		clk_game = 1;
	end
	else begin
		clk_game = 0;
	end
end

always@(posedge clk_100ms)begin //diff随游戏时间的增加而减少，从而使clk_game频率越来越高
	count1 = count1 + 1;			  //通过对diff（difficult）的改变来改变背景的移动速度，进而增加游戏难度
	if(reset == 1)begin
		diff = 60;
	end else
	if(count1 >= 50)begin
		count1 = 0;
		if(diff > 20)
			diff = diff - 4;
		else diff = diff;
	end
end

always@(posedge clk_game)begin//用来控制背景移动的时钟，clk_game来控制背景的移动速度
if(clr == 1)begin					//清屏操作
		ground = 0;
		X_tree1 = 1200;
		X_tree2 = 900;
	end
else begin
	if(shut == 1 || collision1 == 1)begin   //判断游戏是否结束或暂停
		ground = ground;
	end else if(reset == 1)begin
		ground = 64;
	end
	else if(ground <= 576)						//ground为控制背景显示的指针，ground为地面显示的开始位置
		ground = ground + 1;
	else ground = 64;
	
	if(reset == 1)
		X_tree1 = 1200;
	else if(shut == 1 || collision1 == 1)begin		//判断游戏是否结束或暂停
		X_tree1 = X_tree1;
	end
	else if(X_tree1 > 0 )
		X_tree1 = X_tree1 -1;								//控制树（障碍物）的循环移动
	else X_tree1 = 1200;
	
	 if(reset == 1)											//复位操作
		X_tree2 = 900;
	else if(shut == 1 || collision1 == 1)begin		//判断游戏是否结束或暂停
		X_tree2 = X_tree2;
	end
	else if(X_tree2 > 0 )
		X_tree2 = X_tree2 -1;
	else X_tree2 = 900;
	
	if(reset == 1)begin										//复位操作
		X_cloud1 = 800;
		X_cloud2 = 700;
	end else
	if(shut == 1 || collision1 == 1)begin				//判断游戏是否结束或暂停
		X_cloud1 = X_cloud1;
		X_cloud2 = X_cloud2;
		//X_cloud3 = X_cloud3;
	end 
	else begin
		if(X_cloud1 > 0 )
			X_cloud1 = X_cloud1 -1;							//云彩的循环移动
		else X_cloud1 = 800;
		if(X_cloud2 > 0)
			X_cloud2 = X_cloud2 - 1;
		else X_cloud2 = 700;
		/*if(X_cloud3 > 0)
			X_cloud3 = X_cloud3 - 1;
		else X_cloud3 = 600;*/
	end
end
end

assign show_ground1 = (high_ground1*640 + (ground+h_count)%512);			//显示地面移动的指针，ROM的输入
assign show_ground2 = (high_ground2*640 + (ground+h_count)%512);


always@(*)begin 
if(h_count >= x1 && h_count < x2 && v_count >= Y && v_count < Y+60)begin//判断是否到了显示恐龙的位置
		y = v_count - Y;
		x = h_count - x1;
		addr = y * 60 + x;
		if(mode == 1 || high == 1)begin//通过mode控制draw_demon1和draw_demon2，进而控制小恐龙的显示
			draw_demon1 = 1;
			draw_demon2 = 0;
		end 
		else begin
			draw_demon2 = 1;
			draw_demon1 = 0;
		end
end
else begin
	draw_demon1 = 0;						//如果不在显示区域，则变量为0
	draw_demon2 = 0;
end

if(v_count >= Y_ground1 && v_count < Y_ground1+60 && h_count >= 1 && h_count <= 640)begin//判断是否到了显示地1的位置
	in_ground1 = 1;
	high_ground1 = v_count - Y_ground1;						
end
else begin
	in_ground1 = 0;
end


if(v_count >= Y_tree1 && v_count <Y_tree1+100 && h_count >= X_tree1 && h_count <= X_tree1+70 && h_count >= 1 && h_count <= 640)begin//判断是否到了显示树1的位置
	in_tree1= 1;
	x_t1 = h_count - X_tree1;
	y_t1 = v_count - Y_tree1;
	show_tree1   = (y_t1 * 70 + x_t1);		//ROM的输入端
end
else begin
	in_tree1 = 0;
end

if(v_count >= Y_tree2 && v_count <Y_tree2+60 && h_count >= X_tree2 && h_count <= X_tree2+70 && h_count >= 1 && h_count <= 640)begin//判断是否到了显示树1的位置
	in_tree2= 1;
	x_t2 = h_count - X_tree2;
	y_t2 = v_count - Y_tree2;
	show_tree2  = (y_t2 * 70 + x_t2);		//ROM的输入端
end
else begin
	in_tree2 = 0;
end

//判断是否到了显示云彩的位置
if(v_count >= Y_cloud1 && v_count < Y_cloud1 +70 && h_count >= X_cloud1 && h_count < X_cloud1+100 && h_count >= 1 && h_count <= 640)begin
	in_cloud = 1;
	x_c1 = h_count - X_cloud1;
	y_c1 = v_count - Y_cloud1;
	show_cloud = (y_c1 * 100 + x_c1);		//ROM的输入端
end else
if(v_count >= Y_cloud2 && v_count < Y_cloud2 +70 && h_count >= X_cloud2 && h_count < X_cloud2+100 && h_count >= 1 && h_count <= 640)begin
	in_cloud = 1;
	x_c2 = h_count - X_cloud2;
	y_c2 = v_count - Y_cloud2;
	show_cloud = (y_c2 * 100 + x_c2);		//ROM的输入端
end
else begin
	in_cloud = 0;
end

//判断是否到了显示结束画面的位置
if(v_count >= Y_over && v_count < Y_over+70 && h_count >= X_over && h_count < X_over+400)begin
	in_over = 1;
	x_v = h_count - X_over;
	y_v = v_count - Y_over;
	show_over = y_v * 400 + x_v;				//ROM的输入端
end
else in_over = 0;

red = 0;blue = 0;green = 0;					//vga显示的初始化
 
if(video == 1) begin
	red = 1;
	green = 1;
	blue = 1;
end


if(in_tree1 == 1)begin							//如果在显示区域，则给rgb赋值
	if(color_tree1[0] == 0)begin				//ROM输出
		red =0;
		green =0;
		blue = 0;
	end 
end else if(in_tree2 == 1)begin
	if(color_tree2[0] == 0)begin
		red = 0;green = 0;blue= 0;
	end
end

if(draw_demon1 == 1 )begin							//如果在显示区域，则给rgb赋值
		if(color1[0] == 0)begin						//ROM输出
				red = 0;
				green = 0;
				blue = 0;
		end
end else if(draw_demon2 == 1  )begin
			if(color2[0] == 0) begin
						red = 0;
						green = 0;
						blue =0;
					end
end

if(in_ground1 == 1)begin							//如果在显示区域，则给rgb赋值
	if(color_ground1[0] == 0)begin				//ROM输出
		red = color_ground1[0];
		green = color_ground1[0];
		blue = color_ground1[0];
	end
end else if(in_ground2 == 1)begin
	if(color_ground2[0] == 0)begin
		red = color_ground2[0];
		green = color_ground2[0];
		blue = color_ground2[0];
	end
end

if(in_cloud == 1)begin							//如果在显示区域，则给rgb赋值
	if(color_cloud[0] ==0)begin				//ROM输出
		red = 0;green = 0;blue = 0;
	end
end
//检测小恐龙碰撞的模块，选取坐标特征点判断（其中选取小恐龙的5个特征点进行识别）
if((x1+53 >= X_tree1 + 20) &&( x1 + 53 <= X_tree1 +53) &&( Y + 17 >= Y_tree1 + 14))
		collision1 = 1;
else if((Y +57 >= Y_tree1 + 14) && (x1 + 35 <= X_tree1 +53 )&& (x1 +35 >= X_tree1 + 20))
		collision1 = 1;
else if	((Y + 57>= Y_tree1 + 14) && (x1 + 19 <= X_tree1 +53 )&&( x1+ 19 >= X_tree1 + 20))
		collision1 = 1;
else if ((Y + 36>= Y_tree1 + 14) && (x1 + 8  <= X_tree1 +53 )&& (x1 +8  >= X_tree1 + 20))
	collision1 = 1;
else if(  (Y + 37 >= Y_tree1 + 14) && (x1 + 21 <= X_tree1 + 53) && (x1 + 21 >= X_tree1 + 20))
	collision1 = 1;
else if( (Y + 17 >= Y_tree2 + 7 ) && (x1 + 53 >= X_tree2 + 11) && (x1 + 53 <= X_tree2 + 57))
	collision1 = 1;
else if( (Y+57 >= Y_tree2 + 7) && (x1 + 35 >= X_tree2 + 11 ) && (x1 + 35 <= X_tree2 + 57))
	collision1 = 1;
else if( (Y+57 >= Y_tree2 + 7) && (x1 + 19 >= X_tree2 + 11 ) && (x1 + 19 <= X_tree2 + 57))
	collision1 = 1;
else if( (Y+36 >= Y_tree2 + 7) && (x1 + 8 >= X_tree2  + 11)  && (x1 + 8 <= X_tree2 + 57))
	collision1 = 1;
else if( (Y+37 >= Y_tree2 + 7) && (x1 + 21 >= X_tree2 + 11) && (x1 + 21 <= X_tree2 + 57))
	collision1 = 1;
else collision1 = 0;

if(collision1 == 1)begin		//如果游戏结束，则显示“game over”
	if(in_over == 1)begin
		red = color_over[0];
		blue = color_over[0];
		green = color_over[0];
	end
end

//将屏幕两侧涂成黑色
if(((h_count >= 0 && h_count <= 64 )||(h_count >= 576 && h_count <= 640))&& v_count >= 0 && v_count <= 480 )begin
	red = 0;
	green = 0;
	blue = 0;
end


end



always@(posedge clk_5ms)begin//小恐龙跳起后在空中的时序控制
if(clr == 1)begin				  //复位与清除操作
	V = 0;
	Y = y1;
end
else begin
	if(jump == 1)begin
		if(Y == y1)begin
			V = V0;
			high = 1;
		end
	end
	else if(Y == y1 && V == 0)
		high = 0;
		
		
	if(high == 1)begin
		if(reset == 1)begin
			V = 0;
			Y = y1;
		end else
		if(shut == 1 || collision1 == 1)begin		//判断游戏是否结束或暂停
			S = S;
			Y = Y;
			V = V;
		end 
		else if(V > -V0)begin
			S = (V0*V0 - V*V)/32;						//利用公式算出小恐龙的位置和速度				
			Y = y1 - S;
			V = V - delta;
		end
		else begin
			V = 0;
			Y = y1;
		end
	end
end
end


endmodule
