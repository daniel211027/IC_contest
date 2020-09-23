`timescale 1ns/10ps
/*
 * IC Contest Computational System (CS)
*/
module CS(Y, X, reset, clk);
input clk, reset; 
input 	[7:0] X;
output reg [9:0] Y;
reg [10:0] sum=0;
reg [7:0] XS[8:0];   //X serious (8bits*9)
reg [7:0] Xappr;
reg [4:0] i;
always@(posedge clk)begin
  if(reset)
    begin
      for(i=0;i<9;i=i+1)
        XS[i]<=0;
      sum<=0;
    end
  else
    begin
      sum<=sum-XS[8]+X;
      for(i=8;i>0;i=i-1)
        XS[i]<=XS[i-1];
      XS[0]<=X;
      
      //Y<=((sum+Xappr)+(Xappr<<3))/8;
    end
end
always @(negedge clk)
begin
  Xappr=0;
  for(i=0;i<9;i=i+1)begin        //Find out Xappr
      if(XS[i]<=sum/9&&XS[i]>Xappr)begin  
        Xappr=XS[i];
      end
    end
    //#0.5
    Y=((sum+Xappr)+(Xappr<<3))/8;
end
endmodule
