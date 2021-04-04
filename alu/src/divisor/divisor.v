`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 25.03.2021 07:00:38
// Design Name: 
// Module Name: divisor
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


module divisor(clk, init, DR, DV, pp, reset);              

input clk; 
input init;
input reset; 
input [2:0] DR;
input [2:0] DV; 
output reg [5:0] pp;
	
    

reg done;
reg sh;
reg rst;
reg add;
reg llenar;
reg asg;
reg [5:0] C;
reg [2:0] B;

reg [1:0] count;

wire z;

reg [2:0] status = 0;

//bloque para asignar la salida


// bloque comparador 
assign z=(B==0)?1:0;


//bloques de registros de desplazamiento para pp y B
always @(negedge clk) begin
   
	if (rst) begin
		pp = {3'b000,DV};
		B = ~DR + 1;
		count = 3;
	end
	else begin 
            if (sh) begin
               pp = pp << 1;
                count = count-1;
            end
            else begin          
                if(asg)
                    pp[5:3]=C[2:0];          
                else begin
                    if (llenar) 
                        pp[0]= 1'b1;
                    else if(done)
                        pp[5:3]=3'b000;
                end
            end
    end

end 

//bloque de add pp
always @(negedge clk) begin
   
	if (rst) begin
		C =0;
	end
	else begin
        if (add) 
         C = pp[5:3] + B;
    end
	
 end



//bloque para actualizar pp


// FSM 
parameter START =0, CHECK =1, ADD =2, SHIFT =3, END1 =4, CHECKCOUNT=5, FILLONE=6, ASSIGNA=7;

always @(posedge clk) begin
	case (status)
	START: begin
		sh=0;
		add=0;
		llenar=0;
		asg=0;
		if (init || reset) begin
			status=SHIFT;
			done =0;
			rst=1;
		end
		end
	CHECK: begin 
		done=0;
		rst=0;
		sh=0;
		add=0;
		llenar=0;
		asg=0;
		if (C[3]==1)
			status=FILLONE;
		else
			status=CHECKCOUNT;
		end
	ADD: begin
		done=0;
		rst=0;
		sh=0;
		add=1;
		llenar=0;
		asg=0;
		status=CHECK;
		end
	SHIFT: begin
		done=0;
		rst=0;
		sh=1;
		add=0;
		llenar=0;
		asg=0;
		status=ADD;
        end
        
    ASSIGNA: begin
        done=0;
        rst=0;
        sh=0;
        add=0;
        llenar=0;
        asg=1;
        status=CHECKCOUNT;
        end
		
		
    CHECKCOUNT: begin 
        done=0;
        rst=0;
        sh=0;
        add=0;
        llenar=0;
        asg=0;
        if (count == 0)
            status=END1;
        else
            status=SHIFT;
        end
        
	FILLONE: begin 
        done=0;
        rst=0;
        sh=0;
        add=0;
        llenar=1;
        asg=0;
        status=ASSIGNA;
		end
		
	END1: begin
		done =1;
		rst =0;
		sh =0;
		add =0;
		llenar=0;
		asg=0;
		status =START;
	end
	 default:
		status =START;
	endcase 
	
end 


endmodule