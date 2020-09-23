module LCD_CTRL(clk, reset, datain, cmd, cmd_valid, dataout, output_valid, busy);
input           clk;
input           reset;
input   [7:0]   datain;
input   [2:0]   cmd;
input           cmd_valid;
output  reg [7:0]   dataout;
output   reg     output_valid;
output   reg    busy;
//reg [3:0] index=0;
reg [5:0] origin=0;
reg [2:0] x=0;
reg [2:0] y=0;
reg load=0;
reg [7:0] img [63:0];
reg [7:0] store [15:0];  //for unexpected refresh
reg [3:0] store_index=0;
reg [3:0] state;

//can compare 4*x with x[4:0] 
parameter refresh=0;
parameter Load_Data=1;
parameter Zoom_In=2;
parameter Zoom_Out=3;
parameter Shift_Right=4;
parameter Shift_Left=5;
parameter Shift_Up=6;
parameter Shift_Down=7;

always @ (posedge clk or posedge reset)
begin
  if (reset)
    begin
      busy<=0;
    end
  else
    begin
      if(load==1 & cmd!=Zoom_In)
        begin
          state<=0;
          origin<=0;
          busy<=1;
          output_valid<=0;
        end
      else
        begin
      case(cmd)
        refresh     : begin   
                  	     state<=0;
                        busy<=1;
                        output_valid<=0;
                      end
        Load_Data   : begin   
                        state<=1;
                        busy<=1;
                        output_valid<=0;
                        origin<=0;
                      end
        Zoom_In     : begin   
                        state<=2;
                        busy<=1;
                        output_valid<=0;
                        origin<=18;
                        load<=0;
                      end
        Zoom_Out    : begin   
                       	state<=3;
                       	busy<=1;
                        output_valid<=0;
                        origin<=0;
                      end
        Shift_Right : begin   
                        
                	       output_valid<=0;
                	       busy<=1;
                        if(origin[2:0]<4)
                          begin
                            state<=4;
                            origin<=origin+1;
                          end
                        else
                          begin
                            state<=0;
                          end
                       end
        Shift_Left  : begin
                        
                        busy<=1;
                       	output_valid<=0;
                        if(origin[3:0]!=0)
                          begin
                            state<=5;
                            origin<=origin-1;
                          end
                        else
                          begin
                            state<=0;
                          end
                      end
        Shift_Up    : begin
                        
                        
busy<=1;
                        output_valid<=0;
                        if(origin>7)
                          begin
                            
state<=6;
                            origin<=origin-8;
                          end
                        else
                          begin
                            state<=0;
                          end
                      end
        Shift_Down  : begin
                        
                        busy<=1;
                        output_valid<=0;
                        if(origin<29&&origin<32)
                          begin
                            state<=7;
                            origin<=origin+8;
                          end
                        else
                          begin
                            state<=0;
                          end
                      end
      endcase
      end
      case(state)
                  8 : begin
                        output_valid<=0;
                      end
            refresh : begin
                        //if(load)
                        if(store_index==15)
                          begin
                   	       	busy<=0;
                            store_index<=0;
                            state<=8;
                            //load<=0;
                            //output_valid<=0;
                            
                          end
                        else
                          begin
                            store_index<=store_index+1;
                            
                          end
                        output_valid<=1;
                        dataout<=store[store_index];
                        
                      end
          Load_Data : begin
                	       if(origin==63)
                          begin
                            origin<=0;
                            busy<=0;
                            store_index<=0;
                            state<=8;
                            load<=0;
                          end
                        else
                          begin
                            if(origin[0:0]==0 & origin[3:0]<8)
                              begin
                    	           output_valid<=1;
                                dataout<=datain;
                                store_index<=store_index+1;      
                                store[store_index]<=datain;
                              end
                            else
                              begin
                                output_valid<=0;
                              end 
                                origin<=origin+1;
                            end
                        img[origin]<=datain;   
                      end
        Zoom_In,Shift_Right,Shift_Down,Shift_Left,Shift_Up: 
                      begin
                        /*
                        if(state==Zoom_In &&  load)
                          load<=0;
                        else if (state!=Zoom_In && load)
                          load<=1;
                          */
                        if(store_index==15)
                          begin
                           	busy<=0;
                            store_index<=0;
                            state<=8;
                            x<=0;
                            //load<=0;
                          end
                        else
                          begin
                            store_index<=store_index+1;
                            if(store_index[1:0]==3 & store_index!=0)
                              x<=x+1;
                          	 output_valid<=1;
                          end
                        dataout<=img[store_index+origin+4*x];
                       	store[store_index]<=img[store_index+origin+4*x];
                      end
            Zoom_Out: begin
                        if(store_index==15)
                          begin
                           	busy<=0;
                            store_index<=0;
                            state<=8;
                            x<=0;
                            y<=0;
                            load<=1;
                          end
                        else
                          begin
                            store_index<=store_index+1;
                            if(store_index[1:0]==3 & store_index!=0)
                              begin
                                x<=x+1;
                                y<=0;
                              end
                            else
                              y<=y+1;
                          	 output_valid<=1;
                          end
                        dataout<=img[y+y+16*x];
                       	store[store_index]<=img[y+y+16*x];
                      end
        endcase
    end
end
                                 
endmodule
