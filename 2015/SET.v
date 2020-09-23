module SET (clk ,rst, en,central,radius, mode, busy, valid, candidate);
input clk;
input rst;
input en;
input [23:0] central;
input [11:0] radius;
input [1:0]mode;
output reg busy;
output reg valid;
output   [7:0]candidate;
reg [3:0] i,j;
reg signed [3:0] temp;
wire [6:0] x;
reg [7:0] a,b;
reg [3:0] step;
reg [5:0] count;
//====================================================================
assign candidate=count;
assign x=temp*temp;
reg p,q,r;
always@(posedge clk or posedge rst)
begin
	if(rst)begin
		busy<=0;
		valid<=0;
		step<=12;
	end
	else begin
		case(step)
			////////////////XXXXX////////////////////
			0:	begin
					p<=0;
					
					temp<=i-central[23:20];
					step<=1;
					end
			1:	begin
			    	q<=0;
					a<=x;
					temp<=j-central[19:16];
					step<=2;
				end
			2:	begin
			    	r<=0;
					b<=x;
					temp<=radius[11:8];
					step<=3;
				end
			3:	begin
					if(a+b<=x)
						p<=1;
					temp<=i-central[15:12];
					step<=4;
				end
			////////////YYYYYY/////////////////
			4:	begin
					a<=x;
					temp<=j-central[11:8];
					step<=5;
				end
			5:	begin
					b<=x;
					temp<=radius[7:4];
					step<=6;
				end
			6:	begin
					if(a+b<=x)
						q<=1;
					step<=7;
					temp<=i-central[7:4];
				end
			///////////////ZZZZZZZ/////////////
			7:	begin
					a<=x;
					temp<=j-central[3:0];
					step<=8;
				end
			8:	begin
					b<=x;
					temp<=radius[3:0];
					step<=9;
				end
			9:	begin
					if(a+b<=x)
						r<=1;
					step<=15;
				end
			15:	begin
					case(mode)
						0:	begin
								if(p)
									count<=count+1;
							end
						1:	begin
								if(p&q)
									count<=count+1;
							end
						2:	begin
								if(p^q)
									count<=count+1;
							end
						3:	begin
								if((!p&q&r)||(p&!q&r)||(p&q&!r))
									count<=count+1;
							end
					endcase
					if(i[3]==1'b1)begin
						i<=1;
						if(j[3]==1'b1)begin
							valid<=1;
							step<=11;
						end
						else begin
							step<=0;
							j<=j+1;
						end
					end
					else begin
						step<=0;
						i<=i+1;
						busy<=1;
						j<=j;
						//i<=i;
					end
				end
			11:	begin
					busy<=0;
					valid<=0;
					step<=12;
					j<=1;
					//i<=1;
				end
			12:	begin
					i<=1;
					j<=1;
					step<=0;
					count<=0;
				end
		endcase
	end
end


endmodule


