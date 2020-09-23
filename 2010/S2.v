module S2(clk,
	  rst,
	  S2_done,
	  RB2_RW,
	  RB2_A,
	  RB2_D,
	  RB2_Q,
	  sen,
	  sd);

input clk, rst;
output reg S2_done, RB2_RW;
output reg [2:0] RB2_A;
output reg [17:0] RB2_D;
input [17:0] RB2_Q;
input sen, sd;
/****************************************************/
reg [20:0] RB2_reg;
reg state;
reg [5:0] i;
reg [3:0] j; //num of package

always@(posedge clk or posedge rst)
begin
	if(rst)begin
		RB2_RW<=1;
		RB2_A<=0;
		RB2_D<=0;
		state<=0;
		S2_done<=0;
		i<=0;
		j<=0;
	end
	else begin
		if(j!=8)begin
			case(state)
				0:	begin
						if(!sen)begin
							if(i==20)begin
								i<=0;
								state<=1;
							end
							else begin
								
								i<=i+1;
							end
							RB2_reg[20-i]<=sd;
						end
					end
				1:	begin
						RB2_RW<=0;
						RB2_A<=RB2_reg[20:18];
						RB2_D<=RB2_reg[17:0];
						j<=j+1;
						state<=0;
					end
			endcase
		end
		else begin
			S2_done<=1;
		end
				
	end
end

endmodule
