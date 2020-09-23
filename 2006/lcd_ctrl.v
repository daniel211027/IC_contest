`timescale 1ns/10ps
module LCD_CTRL(clk, reset, IROM_Q, cmd, cmd_valid, IROM_EN, IROM_A, IRB_RW, IRB_D, IRB_A, busy, done);
input clk;
input reset;
input [7:0] IROM_Q;
input [2:0] cmd;
input cmd_valid;
output reg IROM_EN;
output reg[5:0] IROM_A;
output reg IRB_RW;
output reg[7:0] IRB_D;
output reg[5:0] IRB_A;
output reg busy;
output reg done;
/////////////////

reg flag;
reg [7:0] img [63:0];
reg [5:0] i;
reg [5:0] op;
////////////////////////
wire [9:0] average;
assign average=(img[op]+img[op+1]+img[op+8]+img[op+9])>>2;
////////////////////////
reg [1:0] state;
////////////////////////
parameter Write=0;
parameter Shift_U=1;
parameter Shift_D=2;
parameter Shift_L=3;
parameter Shift_R=4;
parameter Average=5;
parameter Mx=6;
parameter My=7;



always@(posedge clk or posedge reset)
begin
    if(reset)begin
        busy<=1;
        state<=0;
        IROM_A<=0;
        IROM_EN<=0;
        IRB_RW<=1;
        done<=0;
        op<=27;
        IRB_A<=0;
        flag<=0;
    end
    else begin
        case(state)
            0:  begin
                    if(IROM_A==63)begin
                        #5;
                        busy<=0;
                        state<=1;
                    end
                    else  begin
                        #5;
                        IROM_A<=IROM_A+1;
                    end
                    img[IROM_A]<=IROM_Q;
                end
            1:  begin
                    case(cmd)
                        Write   :   begin
                                        state<=2;
                                        busy<=1;
                                    end
                        Shift_U :   begin
                                        if(op>7)
                                            op<=op-8;
                                    end
                        Shift_D :   begin
                                        if(op<47)
                                            op<=op+8;
                                    end
                        Shift_L :   begin
                                        if(op[2:0]>0)
                                            op<=op-1;
                                    end
                        Shift_R :   begin
                                        if(op[2:0]<6)
                                            op<=op+1;
                                    end
                        Average :   begin
                                        img[op]<=average;
                                        img[op+1]<=average;
                                        img[op+8]<=average;
                                        img[op+9]<=average;
                                    end
                        Mx      :   begin
                                        img[op]<=img[op+8];
                                        img[op+1]<=img[op+9];
                                        img[op+8]<=img[op];
                                        img[op+9]<=img[op+1];
                                    end
                        My      :   begin
                                        img[op]<=img[op+1];
                                        img[op+1]<=img[op];
                                        img[op+8]<=img[op+9];
                                        img[op+9]<=img[op+8];
                                    end
                    endcase
                end
            2:  begin
                    if(!flag)begin
                        //#5;
                        IRB_D<=img[0];
                        flag<=1;
                        IRB_RW<=0;
                        //IRB_A<=IRB_A+1;
                    end
                    else  begin
                        if(IRB_A==63)begin
                            //#5;
                            done<=1;
                        end
                        else  begin
                            //#5;
                            IRB_D<=img[IRB_A+1];
                            IRB_A<=IRB_A+1;
                        end
                    end
                end
        endcase
    end
end


endmodule

