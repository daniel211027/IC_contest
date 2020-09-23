
module LCD_CTRL(clk, reset, datain, cmd, cmd_valid, dataout, output_valid, busy);
input           clk;
input           reset;
input    [7:0]   datain;
input    [3:0]   cmd;
input           cmd_valid;
output reg [7:0]   dataout;
output  reg        output_valid;
output  reg       busy;



reg [6:0] origin=0;
//reg [2:0] x=0;
//reg [2:0] y=0;
//reg load=0;
reg [7:0] img [107:0];
reg [7:0] store [15:0];  //for unexpected refresh
reg [7:0] fitindex [15:0];
//reg [3:0] store_index=0;
reg [3:0] state;
reg [1:0] rotate;
reg Zoom_mode;
reg [1:0] rotate_con=0;
wire [7:0] fitxy;
wire [3:0] index;
wire [7:0] zoominxy;
reg [1:0] offsetx;
reg [1:0] offsety;
reg [3:0] originl;
reg [3:0] originw;
//reg [7:0] i;
//can compare 4*x with x[4:0] 
parameter Load_Data=0;
parameter Rotate_L=1;
parameter Rotate_R=2;
parameter Zoom_In=3;
parameter Zoom_fit=4;
parameter Shift_Right=5;
parameter Shift_Left=6;
parameter Shift_Up=7;
parameter Shift_Down=8;
//parameter Refresh=9;
//parameter Normal=11;
parameter Decision=10;
parameter Load_output=12;


parameter Zoom_Fit_mode=0;

wire [3:0] index1;
always @(*)
begin
  case(Zoom_mode)
    Zoom_Fit_mode:dataout=img[fitxy];
    default:dataout=img[zoominxy];
  endcase
  /*
  if (Zoom_mode==Zoom_Fit_mode)
    dataout=img[fitxy];
  else
  	 dataout=img[zoominxy];*/
end
//assign dataout=(Zoom_mode==Zoom_Fit_mode)?img[fitxy]:img[zoominxy];
//assign index=(offsetx+offsety)+(offsety+offsety)+offsety;
assign fitxy=fitindex[offsetx+{offsety,2'b0}];
//assign index1=offsety+originw;
//assign zoominxy=(offsetx+originl)+({index1,3'b0}+{index1,2'b0});
assign zoominxy=(offsetx+originl)+({offsety+originw,3'b0}+{offsety+originw,2'b0});
//assign zoominxy=offsetx+offsety+originw*12;



always @ (negedge reset)
begin
  fitindex[0]=13;
  fitindex[1]=16;
  fitindex[2]=19;
  fitindex[3]=22;
  fitindex[4]=37;
  fitindex[5]=40;
  fitindex[6]=43;
  fitindex[7]=46;
  fitindex[8]=61;
  fitindex[9]=64;
  fitindex[10]=67;
  fitindex[11]=70;
  fitindex[12]=85;
  fitindex[13]=88;
  fitindex[14]=91;
  fitindex[15]=94;
end 

//reg [11:0] a=0;
always @ (posedge clk or posedge reset)
begin
  //a<=a+1;
  if (reset)
    begin
      busy<=0;
      Zoom_mode<=0;
      state<=10;
    end
  else
    begin
      case(state)
          Decision:     begin
                          if(cmd==0)
                            begin
                              state<=Load_Data;
                              busy<=1;
                              output_valid<=0;
                              rotate_con<=0;
                              origin<=0;
                            end
                          else if (cmd==1 & Zoom_mode==Zoom_Fit_mode)
                            begin
                              busy<=1;
                              output_valid<=1;
                              if (rotate_con==0)
                                begin
                                  rotate_con<=1;
                                  state<=Rotate_L;
                                  offsetx<=3;
                                  offsety<=0;
                                end
                              else
                                begin
                                  rotate_con<=0;
                                  offsetx<=0;
                                  offsety<=0;
                                  state<=Load_output;
                                end
                            end
                            else if (cmd==2 & Zoom_mode==Zoom_Fit_mode)
                              begin
                                              busy<=1;
                                              output_valid<=1;
                                              if (rotate_con==0)
                                                begin
                                                  rotate_con<=2;
                                                  state<=Rotate_R;
                                                  offsetx<=0;
                                                  offsety<=3;
                                                end
                                                //origin<=22;
                                              else
                                                begin
                                                  rotate_con<=0;
                                                  offsetx<=0;
                                                  offsety<=0;
                                                  state<=Load_output;
                                                end
                              end
                            else if(cmd==3)
                              begin
                                  	     	     state<=Zoom_In;
                                              busy<=1;
                                              output_valid<=1;
                                              Zoom_mode<=1;
                                              originl<=4;
                                              originw<=3;
                                              case(rotate_con)
                                                0:begin
                                                    offsetx<=0;
                                                    offsety<=0;
                                                  end
                                                1:begin
                                                    offsetx<=3;
                                                    offsety<=0;
                                                  end
                                                2:begin
                                                    offsetx<=0;
                                                    offsety<=3;
                                                  end
                                              endcase
                              end
                          else if (cmd==4)
                            begin
                                                busy<=1;
                                                output_valid<=1;
                                                Zoom_mode<=0;
                                                case(rotate_con)
                                                  0:begin 
                                                      //rotate_con<=0;
                                                      offsetx<=0;
                                                      offsety<=0;
                                                      state<=Load_output;
                                                    end
                                                  1:begin 
                                                      //rotate_con<=1;
                                                      state<=Rotate_L;
                                                      offsetx<=3;
                                                      offsety<=0; 
                                                    end
                                                  2:begin 
                                                      //rotate_con<=2;
                                                      state<=Rotate_R;
                                                      offsetx<=0;
                                                      offsety<=3;
                                                    end
                                                endcase
                            end
                          else if (cmd==5  & Zoom_mode)
                            begin
                                                state<=Zoom_In;
                                                busy<=1;
                                                output_valid<=1;
                                                //Zoom_mode<=1;
                                                case(rotate_con)
                                                  0:begin
                                                      if(originl<8)
                                                        begin
                                                          originl<=originl+1;
                                                          offsetx<=0;
                                                          offsety<=0;
                                                        end
                                                    end
                                                  1:begin
                                                      if(originw<5)
                                                        begin
                                                          originw<=originw+1;
                                                          offsetx<=3;
                                                          offsety<=0;
                                                        end
                                                    end
                                                  2:begin
                                                      if(originw>0)
                                                        begin
                                                          originw<=originw-1;
                                                          offsetx<=0;
                                                          offsety<=3;
                                                        end
                                                    end
                                                endcase
                            end
                            else if (cmd==6  & Zoom_mode)
                              begin
                                                state<=Zoom_In;
                                                busy<=1;
                                                output_valid<=1;
                                                //Zoom_mode<=1;
                                                case(rotate_con)
                                                  0:begin
                                                      if(originl>0)
                                                        begin
                                                          originl<=originl-1;
                                                          offsetx<=0;
                                                          offsety<=0;
                                                        end
                                                    end
                                                  1:begin
                                                      if(originw>0)
                                                        begin
                                                          originw<=originw-1;
                                                          offsetx<=3;
                                                          offsety<=0;
                                                        end
                                                    end
                                                  2:begin
                                                      if(originw<5)
                                                        begin
                                                          originw<=originw+1;
                                                          offsetx<=0;
                                                          offsety<=3;
                                                        end
                                                    end
                                                endcase
                              end
                              else if (cmd==7  & Zoom_mode)
                                begin
                                  state<=Zoom_In;
                                                busy<=1;
                                                output_valid<=1;
                                                //Zoom_mode<=1;
                                                case(rotate_con)
                                                  0:begin
                                                      if(originw>0)
                                                        begin
                                                          originw<=originw-1;
                                                          offsetx<=0;
                                                          offsety<=0;
                                                        end
                                                    end
                                                  1:begin
                                                      if(originl<8)
                                                        begin
                                                          originl<=originl+1;
                                                          offsetx<=3;
                                                          offsety<=0;
                                                        end
                                                    end
                                                  2:begin
                                                      if(originl>0)
                                                        begin
                                                          originl<=originl-1;
                                                          offsetx<=0;
                                                          offsety<=3;
                                                        end
                                                    end
                                                endcase
                                end
                                else
                                  begin
                                                state<=Zoom_In;
                                                busy<=1;
                                                output_valid<=1;
                                                //Zoom_mode<=1;
                                                case(rotate_con)
                                                  0:begin
                                                      if(originw<5)
                                                        begin
                                                          originw<=originw+1;
                                                          offsetx<=0;
                                                          offsety<=0;
                                                        end
                                                    end
                                                  1:begin
                                                      if(originl>4)
                                                        begin
                                                          originl<=originl-1;
                                                          offsetx<=3;
                                                          offsety<=0;
                                                        end
                                                    end
                                                  2:begin
                                                      if(originl<8)
                                                        begin
                                                          originl<=originl+1;
                                                          offsetx<=0;
                                                          offsety<=3;
                                                        end
                                                    end
                                                endcase
                                  end
                                end
            
        Load_Data:      begin
                          if(origin==107)
                            begin
                              origin<=0;
                              //busy<=1;
                              output_valid<=1;
                              //store_index<=0;
                              state<=Load_output;
                              //load<=0;
                              offsetx<=0;
                              offsety<=0;
                            end
                          else
                            begin
                              origin<=origin+1;
                            end
                          img[origin]<=datain;   
                        end
        Load_output:    begin
                          if(offsetx==3)
                            begin
                              if(offsety==3)
                                begin
                                  state<=Decision;
                                  output_valid<=0;
                                  busy<=0;
                                  
                                end
                              offsety<=offsety+1;
                            end
                          offsetx<=offsetx+1;
                        end
           Rotate_L:    begin
                            begin
                              if(offsety==3)
                                begin
                                  if(offsetx==0)
                                    begin
                                      state<=Decision;
                                      output_valid<=0;
                                      busy<=0;
                                    end
                                  offsetx<=offsetx-1;
                                end
                              offsety<=offsety+1;
                            end
                        end
           Rotate_R:    begin
                          if(offsety==0)
                            begin
                              if(offsetx==3)
                                begin
                                  state<=Decision;
                                  output_valid<=0;
                                  busy<=0;
                                  //test.over<=1;
                                end
                                offsetx<=offsetx+1;
                            end
                            offsety<=offsety-1;
                        end
           Zoom_In:     begin
                          case (rotate_con)
                            0:  begin
                                  if(offsetx==3)
                                    begin
                                      if(offsety==3)
                                        begin
                                          state<=Decision;
                                          output_valid<=0;
                                          busy<=0;
                                          //test.over<=1;
                                  	     end
                              	       offsety<=offsety+1;
                                    end
                              	   offsetx<=offsetx+1;
                                end
                            1:  begin
                                  if(offsety==3)
                                    begin
                                      if(offsetx==0)
                                        begin
                                          state<=Decision;
                                          output_valid<=0;
                                          busy<=0;
                                          //test.over<=1;
                                  	     end
                              	       offsetx<=offsetx-1;
                                    end
                              	   offsety<=offsety+1;
                                end
                            2:  begin
                                  if(offsety==0)
                                    begin
                                      if(offsetx==3)
                                        begin
                                          state<=Decision;
                                          output_valid<=0;
                                          busy<=0;
                                          //test.over<=1;
                                  	     end
                              	       offsetx<=offsetx+1;
                                    end
                              	   offsety<=offsety-1;
                                end
                          endcase
                        end 
        endcase
    end
end
                                 
endmodule