
`timescale 1ns/10ps
module LBP ( clk, reset, gray_addr, gray_req, gray_ready, gray_data, lbp_addr, lbp_valid, lbp_data, finish);
input   	clk;
input   	reset;
output reg [13:0] 	gray_addr;
output reg        	gray_req;
input   	gray_ready;
input   [7:0] 	gray_data;
output reg [13:0] 	lbp_addr;
output reg 	lbp_valid;
output reg [7:0] 	lbp_data;
output reg 	finish;
//====================================================================
reg [7:0] sub [8:0]; //sub_array
reg [3:0] i;  //index for sub_array
reg [2:0] state,next_state;
wire en[7:0];
////Calculate gc
wire [7:0] gc;
//reg [20:0]c=0;


assign en[0]=(sub[0]>=sub[4])?1:0;
assign en[1]=(sub[1]>=sub[4])?1:0;
assign en[2]=(sub[2]>=sub[4])?1:0;
assign en[3]=(sub[3]>=sub[4])?1:0;
assign en[4]=(sub[5]>=sub[4])?1:0;
assign en[5]=(sub[6]>=sub[4])?1:0;
assign en[6]=(sub[7]>=sub[4])?1:0;
assign en[7]=(sub[8]>=sub[4])?1:0;

//assign gc=((en[0]+{en[1],1'b0})+({en[2],2'b0}+{en[3],3'b0}))+(({en[4],4'b0}+{en[5],5'b0})+({en[6],6'b0}+{en[7],7'b0}));
assign gc={en[7],en[6],en[5],en[4],en[3],en[2],en[1],en[0]};

//the same
//assign gc={sub[8]>=sub[4],sub[7]>=sub[4],sub[6]>=sub[4],sub[5]>=sub[4],sub[3]>=sub[4],sub[2]>=sub[4],sub[1]>=sub[4],sub[0]>=sub[4]};
//reg flag=0;

always@(posedge clk or posedge reset)
begin
  //c<=c+1;
    if(reset)begin
        finish<=0;
        lbp_valid<=0;
        gray_addr<=0;
        i<=0;
        state<=0;
        gray_req<=1;
        lbp_addr<=129;
    end
    else begin
        //state<=next_state;
        case(state)
            0:  begin   //Read in nine elements
                    if(i==9)begin
                        state<=1;
                        i<=0;
                    end
                    else begin
                        i<=i+1;
                        /*
                        if(gray_addr[1:0]==2&gray_addr<lbp_addr)
                            gray_addr<=lbp_addr-1;
                        else if (gray_addr[1:0]==2)
                            gray_addr<=lbp_addr+127;
                        else
                            gray_addr<=gray_addr+1;*/
                        //area is the best, but timing is the worst (setup time violation)
                        /*
                        if(gray_addr[1:0]==2)
                            gray_addr<=gray_addr+126;
                        else
                            gray_addr<=gray_addr+1;
                        */

                        //area is better~
                        
                        if(gray_addr==lbp_addr-127)
                            gray_addr<=lbp_addr-1;
                        else if (gray_addr==lbp_addr+1)
                            gray_addr<=lbp_addr+127;
                        else
                            gray_addr<=gray_addr+1;
                            


                        //area is worse..
                        /*
                        case(gray_addr)
                            lbp_addr-127:gray_addr<=lbp_addr-1;
                            lbp_addr+1:gray_addr<=lbp_addr+127;
                            default:gray_addr<=gray_addr+1;
                        endcase
                        */
                    end
                    
                          
                    sub[i]<=gray_data;
                end
            1:  begin
                    
                    lbp_valid<=1;
                    lbp_data<=gc;
                    state<=2;
                    if(lbp_addr[6:0]!=126)
                        gray_addr<=lbp_addr-126;
                    
                end
            2:  begin
                    //when lbp_addr%128==126 , change to the next row
                    if(lbp_addr[6:0]==126)begin
                        if(lbp_addr==16254)begin    //Ending signal
                          finish<=1;
                          gray_req<=0;
                        end
                        else
                          lbp_addr<=lbp_addr+3;
                          gray_addr<=lbp_addr-126;
                          state<=0;
                    end
                    else begin
                        /*
                        lbp_addr<=lbp_a
                        ddr+1;
                        sub[1]<=sub[2];
                        sub[0]<=sub[1];
                        sub[6]<=sub[7];
                        sub[7]<=sub[8];
                        sub[3]<=sub[4];
                        sub[4]<=sub[5];

                        sub[2]<=gray_data;
                        gray_addr<=lbp_addr+2;
                        state<=3;

                        */
                        //best version
                        lbp_addr<=lbp_addr+1;
                        gray_addr<=lbp_addr+1;
                        state<=3;

                    end
                    
                end
            3:  begin
                    //change column by column
                    
                    /*
                    sub[5]<=gray_data;
                    gray_addr<=lbp_addr+129;
                    */
                    //best version
                    sub[1]<=sub[2];
                    sub[0]<=sub[1];
                    sub[6]<=sub[7];
                    sub[7]<=sub[8];
                    sub[3]<=sub[4];
                    sub[4]<=sub[5];

                    sub[2]<=gray_data;
                    gray_addr<=lbp_addr+2;
                    

                    state<=4;
                end
            4:  begin
                    /*
                    sub[8]<=gray_data;
                    state<=1;
                    */

                    //best version
                    sub[5]<=gray_data;
                    gray_addr<=lbp_addr+129;
                    state<=5;
                end
            5:  begin
                    sub[8]<=gray_data;
                    state<=1;
                end
            default: begin  end
        endcase
    end
end

/*
always@(*)
begin
    case(state)
        0:  begin
                next_state=(i==9)?1:0;
            end
        1:  begin
                next_state=2;
            end
        2:  begin
                next_state=(lbp_addr[6:0]==126)?0:3;
                  //the same performance
            //    if(lbp_addr[6:0]==126)
           //         next_state=0;
            //    else
           //         next_state=3;
                    
            end
        3:  begin
                next_state=4;
            end
        4:  begin
                next_state=5;
            end
        5:  begin
                next_state=1;
            end
        default:begin next_state=0; end
    endcase
end
*/

//====================================================================
endmodule
