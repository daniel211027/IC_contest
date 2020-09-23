module triangle (clk, reset, nt, xi, yi, busy, po, xo, yo);
   input clk, reset, nt;
   input [2:0] xi, yi;
   output reg busy, po;
   output reg [2:0] xo, yo;
   reg [3:0] state;
   reg [2:0] x1,x2,x3,y1,y2,y3;
   reg [1:0]i;
   reg [3:0]m,n;
   wire a,b,c,o,a1,b1,c1;
   wire signed [5:0]d,e,f,g,h,j;
   assign a=(n<=y2&d<=e)?1:0;
   assign b=(n>=y2&f>=g)?1:0;
   assign c=((m==x3&n>=y1&n<=y3)||(n==y2&m<=x2&m>=x1))?1:0;
   assign a1=(n<=y2&d>=e)?1:0;
   assign b1=(n>=y2&f<=g)?1:0;
   assign c1=((m==x3&n>=y1&n<=y3)||(n==y2&m>=x2&m<=x1))?1:0;
   //assign c1=((m==x3&n>=y1&n<=y3)||(n==y2&m<=x2&m>=x1))?1:0;
   
   assign d=(m-x1)*(y2-y1);
   assign e=(x2-x1)*(n-y1);
   assign f=(m-x3)*(y2-y3);
   assign g=(x2-x3)*(n-y3);
   
   assign h=m-x1;
   assign j=m-x2;
   assign o=(h*j<=0)?1:0;

   

   always @(posedge clk or posedge reset)
   begin
      if(reset)begin
         state<=0;
         i<=0;
         busy<=1;
         po<=0;
      end
      else begin
         case(state)
            0: begin
                  busy<=0;
                  state<=1;
                  m<=0;
                  n<=0;
               end
            1: begin
                  if(i==0)begin
                     i<=i+1;
                  end
                  else if(i==1)begin
                     x1<=xi;
                     y1<=yi;
                     i<=i+1;
                  end
                  else if (i==2)begin
                     x2<=xi;
                     y2<=yi;
                     i<=i+1;
                     busy<=1;
                  end
                  else begin
                     x3<=xi;
                     y3<=yi;
                     state<=2;
                     i<=1;
                 end
               end
            2: begin
                  if(m==7)begin
                     m<=0;
                     if(n==7)begin
                        busy<=0;
                        state<=0;
                     end
                     else begin
                        n<=n+1;
                        state<=3;
                     end
                  end
                  else begin
                     m<=m+1;
                     state<=3;
                  end
               end
            3: begin
                  if(x2>x1)begin
                     if(((a||b)||c)&o)begin
                        state<=4;
                        po<=1;
                        xo<=m;
                        yo<=n;
                     end
                     else begin
                        state<=2;
                        po<=0;
                      end
                  end
                  else begin
                     if(((a1||b1)||c1)&o)begin
                        state<=4;
                        po<=1;
                        xo<=m;
                        yo<=n;
                     end
                     else begin
                        state<=2;
                        po<=0;
                      end
                  end
               end
            4: begin
                  
                  po<=0;
                  state<=2;
               end
         endcase
      end

   end   


  

   
endmodule