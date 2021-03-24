`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 23.03.2021 19:29:09
// Design Name: 
// Module Name: divfreq
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module divfreq(clk, clk1);

input clk;
output reg clk1;
reg [27:0] cont;



always @(posedge clk)begin 

	if(cont < 'd50_000)begin
		cont = cont + 1;
		end

	else begin 
	 clk1 = !clk1;
	 cont = 0;
		
		end
		
end
endmodule 
