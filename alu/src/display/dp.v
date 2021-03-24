`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 23.03.2021 19:33:56
// Design Name: 
// Module Name: dp
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


module dp(clk, sw, sseg, an);

input clk;
input [5:0] sw;
output [6:0] sseg;
output reg[7:0] an;
reg [1:0] cont;
reg [3:0] bcd;
reg [7:0]u;
reg [7:0]d;
reg [7:0]c;
reg [7:0]h;
wire clk1;

divfreq div(clk, clk1);
BCDtoSSeg ssdin(.BCD(bcd), .SSeg(sseg));

always @(*)begin
	if(sw > 100)begin
		c = sw / 100;
		h = sw % 100;
		d = h / 10;
		u = h % 10;
		end
	else begin
		c = 0;
		d = sw / 10;
		u = sw % 10;
		end
	

end

always @(posedge clk1)begin
cont = cont + 1;

case(cont)

	2'b00: begin bcd = u; an = 8'b11111110; end
	2'b01: begin bcd = d; an = 8'b11111101; end
	2'b10: begin bcd = c; an = 8'b11111011; end

	endcase
	
end
endmodule
