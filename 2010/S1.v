module S1(clk,
	  rst,
	  RB1_RW,
	  RB1_A,
	  RB1_D,
	  RB1_Q,
	  sen,
	  sd);

  input clk, rst;
  output reg RB1_RW;      // control signal for RB1: Read/Write
  output reg [4:0] RB1_A; // control signal for RB1: address
  output reg [7:0] RB1_D; // data path for RB1: input port
  input [7:0] RB1_Q;  // data path for RB1: output port
  output reg sen, sd;
/****************************************************/

reg [4:0] state;
reg [5:0] index; //index for s1_reg
reg [2:0] addr;
reg [5:0] i;

always@(posedge clk or posedge rst)
begin
	if(rst)begin
		RB1_RW<=1;
		sen<=1;
		RB1_A<=17;
		//RB1_D<=0;
		sd<=0;
		index<=0;

		addr<=7;
		state<=0;
		i<=0;
	end
	else begin
		RB1_RW<=1;
		case(state)
			0:	begin
					addr<=addr+1;
					state<=1;
				end
			1:	begin
					if(i<3)begin
						sd<=addr[2-i];
						if(i==2) RB1_A<=RB1_A-1;
						
					end
					else begin
						if(RB1_A==5'b11111)begin
							state<=2;
							RB1_A<=17;
						end
						else begin
							RB1_A<=RB1_A-1;
							
						end
						sd<=RB1_Q[7-addr];
					end
					sen<=0;
					i<=i+1;
				end
			2:	begin
					sen<=1;
					i<=0;
					state<=0;
				end
		endcase
	end
end
  

endmodule
