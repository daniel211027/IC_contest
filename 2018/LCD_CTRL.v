module LCD_CTRL(clk, reset, cmd, cmd_valid, IROM_Q, IROM_rd, IROM_A, IRAM_valid, IRAM_D, IRAM_A, busy, done);
input clk;
input reset;
input [3:0] cmd;
input cmd_valid;
input [7:0] IROM_Q;
output reg IROM_rd;
output reg [5:0] IROM_A;  
output reg IRAM_valid;
output reg [7:0] IRAM_D;
output reg [5:0] IRAM_A;
output reg busy;
output reg done;
reg load_flag;
reg [5:0] op=27;

reg [7:0] img [63:0];
reg flag;
wire [9:0] compare;
wire [7:0] compare_MIN;
wire [7:0] compare_MAX;
parameter write=0;
parameter Shift_U=1;
parameter Shift_D=2;
parameter Shift_L=3;
parameter Shift_R=4;
parameter Max=5;
parameter Min=6;
parameter Average=7;
parameter CCR=8;
parameter CR=9;
parameter Mx=10;
parameter My=11;


wire [7:0] A0,A1,A2,A3;
//MAX
assign A0=(img[op+1]>img[op])?img[op+1]:img[op];
assign A1=(img[op+8]>img[op+9])?img[op+8]:img[op+9];
assign compare_MAX=(A0>A1)?A0:A1;
//MIN
assign A2=(img[op+1]>img[op])?img[op]:img[op+1];
assign A3=(img[op+8]>img[op+9])?img[op+9]:img[op+8];
assign compare_MIN=(A2>A3)?A3:A2;
//AVE
assign compare=((img[op]+img[op+1])+(img[op+8]+img[op+9]))>>2;

always@(posedge clk or posedge reset)
begin
	if(reset)begin
		IROM_rd<=1;
		IROM_A<=0;
		IRAM_A<=0;
		done<=0;
		flag<=0;
		load_flag<=0;
		op<=27;
	end
	else begin
		case(load_flag)
		0	:	begin
						if(IROM_A==63)begin
							busy<=0;
							load_flag<=1;
						end
						else  begin
							IROM_A<=IROM_A+1;
						end
						img[IROM_A]<=IROM_Q;
					end
		1:		begin
					case(cmd)
						write	:	begin
										if(!flag)begin
											IRAM_D<=img[0];
											busy<=1;
											flag<=1;
										end
										else  begin
											if(IRAM_A==63)begin
												done<=1;
											end
											else  begin
												IRAM_D<=img[IRAM_A+1];
												IRAM_A<=IRAM_A+1;
											end
										end
										IRAM_valid<=1;
									end
					
						Shift_U :	begin
										if(op>7)
											op<=op-8;
									end
						Shift_D	:	begin
										if(op<48)
											op<=op+8;
									end
						Shift_L	:	begin
										if(op[2:0]>0)
											op<=op-1;
									end
						Shift_R	:	begin
										if(op[2:0]<6)
											op<=op+1;
									end
						Max		:	begin
										img[op+1]<=compare_MAX;
										img[op+8]<=compare_MAX;
										img[op+9]<=compare_MAX;
										img[op]<=compare_MAX;
									end
						Min		:	begin
										img[op+1]<=compare_MIN;
										img[op+8]<=compare_MIN;
										img[op+9]<=compare_MIN;
										img[op]<=compare_MIN;
									end
						Average	:	begin
										img[op+1]<=compare;
										img[op+8]<=compare;
										img[op+9]<=compare;
										img[op]<=compare;
									end
						CCR		:	begin
										img[op]<=img[op+1];
										img[op+1]<=img[op+9];
										img[op+9]<=img[op+8];
										img[op+8]<=img[op];
									end
						CR		:	begin
										img[op]<=img[op+8];
										img[op+1]<=img[op];
										img[op+9]<=img[op+1];
										img[op+8]<=img[op+9];
									end
						Mx		:	begin
										img[op]<=img[op+8];
										img[op+8]<=img[op];
										img[op+9]<=img[op+1];
										img[op+1]<=img[op+9];
									end
						My		:	begin
										img[op]<=img[op+1];
										img[op+1]<=img[op];
										img[op+9]<=img[op+8];
										img[op+8]<=img[op+9];
									end
					endcase
				end
		endcase
	end
end
endmodule








