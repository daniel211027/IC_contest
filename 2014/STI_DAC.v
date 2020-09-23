module STI_DAC(clk ,reset, load, pi_data, pi_length, pi_fill, pi_msb, pi_low, pi_end,
	       so_data, so_valid,
	       pixel_finish, pixel_dataout, pixel_addr,
	       pixel_wr);

input		clk, reset;
input		load, pi_msb, pi_low, pi_end; 
input	[15:0]	pi_data;
input	[1:0]	pi_length;
input		pi_fill;
output		reg so_data, so_valid;

output  reg  pixel_finish, pixel_wr;
output  reg [7:0] pixel_addr;
output  reg [7:0] pixel_dataout;

//==============================================================================
reg [2:0] state;
reg [31:0] so_reg;
reg [7:0] pixel_reg;
reg [5:0] i;
reg [5:0] so_length;
reg flag;
reg _flag;
//----------------------------
parameter bits8=0;
parameter bits16=1;
parameter bits24=2;
parameter bits32=3;

always @(posedge clk or posedge reset)
begin
	if(reset)begin
		state<=0;
		i<=0;
		pixel_addr<=255;
		so_valid<=0;
		flag<=1;
		_flag<=1;
		pixel_wr<=0;
		pixel_finish<=0;
	end
	else begin
		case (state)
			0:	begin
					pixel_wr<=0;
					i<=0;
					if(flag)begin
						state<=2;
						flag<=0;
					end	
					else state<=1;
					if(pi_end) so_reg<=0;
					else begin
						case(pi_length)
							bits8:		begin
											so_length<=7;
											if(pi_low)begin
												so_reg<=pi_data[15:8];
											end
											else begin
												so_reg<=pi_data[7:0];
											end
										end
							bits16:		begin
											so_length<=15;
											so_reg<=pi_data;
										end
							bits24:		begin
											so_length<=23;
											if(pi_fill)begin
												so_reg<={pi_data,8'h00};
											end
											else begin
												so_reg<={8'h00,pi_data};
											end
										end
							bits32:		begin
											so_length<=31;
											if(pi_fill)begin
												so_reg<={pi_data,16'h0000};
											end
											else begin
												so_reg<={16'h0000,pi_data};
											end
										end
						endcase
					end
				end
			1:	begin
					state<=2;
					so_valid<=1;
				end
			2:	begin
					if(i==so_length)begin
						state<=3;
						so_valid<=0;
					end
					else begin
						so_valid<=1;
						i<=i+1;
					end
					//給定so_data與pixel
					if(pi_msb)begin
						so_data<=so_reg[so_length-i];
						pixel_reg[7-i[2:0]]<=so_reg[so_length-i];
					end
					else begin
						so_data<=so_reg[i];
						pixel_reg[7-i[2:0]]<=so_reg[i];
					end
					//設定pixel_address與結束時間
					if(i[2:0]==7) begin
						pixel_addr<=pixel_addr+1;
						if(_flag)
							_flag<=0;
						else
							if(pixel_addr==255) pixel_finish<=1;
					end
					else begin
						pixel_wr<=0;
					end
					if(i[2:0]==0)begin
						pixel_wr<=1;
						pixel_dataout<=pixel_reg;
					end
				end
			3:	begin
					
					state<=0;
				end
		endcase
	end
end





endmodule
