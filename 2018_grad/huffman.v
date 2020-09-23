module huffman(clk, reset, gray_valid,gray_data, CNT_valid, CNT1, CNT2, CNT3, CNT4, CNT5, CNT6,
    code_valid, HC1, HC2, HC3, HC4, HC5, HC6,M1,M2,M3,M4,M5,M6);

input clk;
input reset;
input gray_valid;
input [7:0] gray_data;
output reg CNT_valid;
output reg [7:0] CNT1, CNT2, CNT3, CNT4, CNT5, CNT6;
output reg  code_valid;
output reg [7:0] HC1, HC2, HC3, HC4, HC5, HC6;
output reg [7:0] M1, M2, M3, M4, M5, M6;

reg [7:0] seq [6:1];
reg [7:0] C1 [6:2];
reg [7:0] C2 [6:3];
reg [7:0] C3 [6:4];
reg [7:0] C4 [6:5];

reg [2:0] bit[6:1];
reg [6:1] C_union[6:1];
reg [6:1] C_union_index[6:1];
reg [7:0] C_element[6:1];
reg [6:1] C1_union [6:2];  //if the element in Cx is union, then the element of the Cx_union[index]=1
reg [6:1] C2_union [6:3];
reg [6:1] C3_union [6:4];
reg [6:1] C4_union [6:5];
reg [2:0] seq_symbol [6:1];
reg seq_flag;
reg [4:0] state;
reg [7:0] max;
reg gray_flag;
//reg [3:0] i;
reg [4:0] M_num; //may be 1(00000001), 3(00000011), 7(00000111), 15(00001111), 31(00011111)
integer i,j,k,l,m,n,o,p,q,r,s,t;
reg [3:0] union;
//reg a;

always@(posedge clk or posedge reset)
begin
    if(reset)begin
        //a<=0;
        CNT1<=0;
        CNT2<=0;
        CNT3<=0;
        CNT4<=0;
        CNT5<=0;
        CNT6<=0;
        HC1<=0;
        HC2<=0;
        HC3<=0;
        HC4<=0;
        HC5<=0;
        HC6<=0;
        M1<=0;
        M2<=0;
        M3<=0;
        M4<=0;
        M5<=0;
        M6<=0;
        M_num<=1;
        gray_flag<=0;
        //seq_flag<=0;
        CNT_valid<=0;
        code_valid<=0;
        for(t=1;t<7;t=t+1)begin
            bit[t]<=0;
        end
        for(q=1;q<4;q=q+1)begin
            C_union[q]<=0;
        end
        for(k=1;k<5;k=k+1)begin
            C_union_index[k]<=0;
        end
        for(l=0;l<8;l=l+1)begin
            seq[l]<=0;
        end
        for(m=2;m<7;m=m+1)begin
            C1_union[m]<=0;
        end
        for(n=3;n<7;n=n+1)begin
            C2_union[n]<=0;
        end
        for(o=4;o<7;o=o+1)begin
            C3_union[o]<=0;
        end
        for(p=5;p<7;p=p+1)begin
            C4_union[p]<=0;
        end
        r<=0;
        s<=0;
        state<=0;
    end
    else begin
        case(state)
            0:  begin
                    if(gray_valid)begin
                        case(gray_data)
                            1:  CNT1<=CNT1+1;
                            2:  CNT2<=CNT2+1;
                            3:  CNT3<=CNT3+1;
                            4:  CNT4<=CNT4+1;
                            5:  CNT5<=CNT5+1;
                            6:  CNT6<=CNT6+1;
                        endcase
                        gray_flag<=1;
                    end
                    else begin
                        if(gray_flag)
                            state<=1;
                    end
                end
            1:  begin
                    seq[1]<=CNT1;
                    seq_symbol[1]<=1;
                    seq[2]<=CNT2;
                    seq_symbol[2]<=2;
                    seq[3]<=CNT3;
                    seq_symbol[3]<=3;
                    seq[4]<=CNT4;
                    seq_symbol[4]<=4;
                    seq[5]<=CNT5;
                    seq_symbol[5]<=5;
                    seq[6]<=CNT6;
                    seq_symbol[6]<=6;
                    state<=2;
                end
            2:  begin
                    if(seq[1]>=seq[2])begin
                        seq[1]<=seq[2];
                        seq[2]<=seq[1];
                        seq_symbol[1]<=seq_symbol[2];
                        seq_symbol[2]<=seq_symbol[1];
                    end
                    if(seq[3]>=seq[4])begin
                        seq[3]<=seq[4];
                        seq_symbol[3]<=seq_symbol[4];
                        seq[4]<=seq[3];
                        seq_symbol[4]<=seq_symbol[3];
                    end
                    if(seq[5]>=seq[6])begin
                        seq[5]<=seq[6];
                        seq_symbol[5]<=seq_symbol[6];
                        seq[6]<=seq[5];
                        seq_symbol[6]<=seq_symbol[5];
                    end
                    state<=3;
                end
            3:  begin
                    if(seq[2]>=seq[3])begin
                        seq[2]<=seq[3];
                        seq_symbol[2]<=seq_symbol[3];
                        seq[3]<=seq[2];
                        seq_symbol[3]<=seq_symbol[2];
                    end
                    if(seq[4]>=seq[5])begin
                        seq[4]<=seq[5];
                        seq_symbol[4]<=seq_symbol[5];
                        seq[5]<=seq[4];
                        seq_symbol[5]<=seq_symbol[4];
                    end
                    state<=4;
                end
            4:  begin
                    if(seq[3]>=seq[4])begin
                        seq[3]<=seq[4];
                        seq_symbol[3]<=seq_symbol[4];
                        seq[4]<=seq[3];
                        seq_symbol[4]<=seq_symbol[3];
                    end
                    state<=5;
                end
            5:  begin
                    s<=s+1;
                    if(s<4)
                        state<=2;
                    else
                        state<=11;
                end
            11: begin
                    
                    C_union[1]<=6'b000011;
                    if(seq[1]+seq[2]<=seq[3])begin
                        C1[6]<=seq[6];
                        C1[5]<=seq[5];
                        C1[4]<=seq[4];
                        C1[3]<=seq[3];
                        C1[2]<=seq[1]+seq[2];
                        C1_union[2]<=6'b000011;
                        C1_union[6]<=6'b100000;
                        C1_union[5]<=6'b010000;
                        C1_union[4]<=6'b001000;
                        C1_union[3]<=6'b000100;
                        C_union_index[1]<=6'b000010;
                        C_union[2]<=6'b000111;
                    end
                    else if(seq[1]+seq[2]<=seq[4])begin
                        C1[6]<=seq[6];
                        C1[5]<=seq[5];
                        C1[4]<=seq[4];
                        C1[3]<=seq[1]+seq[2];
                        C1[2]<=seq[3];
                        C1_union[3]<=6'b000011;
                        C1_union[6]<=6'b100000;
                        C1_union[5]<=6'b010000;
                        C1_union[4]<=6'b001000;
                        C1_union[2]<=6'b000100;
                        C_union_index[1]<=6'b000100;
                        C_union[2]<=6'b000111;
                    end
                    else if(seq[1]+seq[2]<=seq[5])begin
                        C1[6]<=seq[6];
                        C1[5]<=seq[5];
                        C1[4]<=seq[1]+seq[2];
                        C1[3]<=seq[4];
                        C1[2]<=seq[3];
                        C1_union[4]<=6'b000011;
                        C1_union[6]<=6'b100000;
                        C1_union[5]<=6'b010000;
                        C1_union[3]<=6'b001000;
                        C1_union[2]<=6'b000100;
                        C_union_index[1]<=6'b001000;
                        C_union[2]<=6'b001111;
                    end
                    else if(seq[1]+seq[2]<=seq[6])begin
                        C1[6]<=seq[6];
                        C1[5]<=seq[1]+seq[2];
                        C1[4]<=seq[5];
                        C1[3]<=seq[4];
                        C1[2]<=seq[3];
                        C1_union[5]<=6'b000011;
                        C1_union[6]<=6'b100000;
                        C1_union[4]<=6'b010000;
                        C1_union[3]<=6'b001000;
                        C1_union[2]<=6'b000100;
                        C_union_index[1]<=6'b010000;
                        C_union[2]<=6'b001111;
                    end
                    else begin
                        C1[6]<=seq[1]+seq[2];
                        C1[5]<=seq[6];
                        C1[4]<=seq[5];
                        C1[3]<=seq[4];
                        C1[2]<=seq[3];
                        C1_union[6]<=6'b000011;
                        C1_union[5]<=6'b100000;
                        C1_union[4]<=6'b010000;
                        C1_union[3]<=6'b001000;
                        C1_union[3]<=6'b000100;
                        C_union_index[1]<=6'b100000;
                        C_union[2]<=6'b001111;
                    end
                    state<=12;
                end
            12: begin
                    
                    if(C1[2]+C1[3]<=C1[4])begin
                        C2[6]<=C1[6];
                        C2[5]<=C1[5];
                        C2[4]<=C1[4];
                        C2[3]<=C1[2]+C1[3];
                        C_union_index[2][3]<=1;
                        C2_union[6]<=C1_union[6];
                        C2_union[5]<=C1_union[5];
                        C2_union[4]<=C1_union[4];
                        C2_union[3]<=C1_union[3]|C1_union[2];
                        C_union_index[2]<=C_union_index[1]|6'b000100;
                        C_union_index[2][3]<=1;
                        C_union[3]<=6'b001111;


                    end
                    else if(C1[2]+C1[3]<=C1[5])begin
                        C2[6]<=C1[6];
                        C2[5]<=C1[5];
                        C2[4]<=C1[2]+C1[3];
                        C2[3]<=C1[4];

                        C2_union[6]<=C1_union[6];
                        C2_union[5]<=C1_union[5];
                        C2_union[4]<=C1_union[3]|C1_union[2];
                        C2_union[3]<=C1_union[4];
                        
                        C_union_index[2][4]<=1;
                        if(C_union_index[1][6])
                            C_union_index[2][6]<=1;
                        if(C_union_index[1][5])
                            C_union_index[2][5]<=1;
                        if(C_union_index[1][4])
                            C_union_index[2][3]<=1;
                        C_union[3]<=6'b001111;
                        
                        
                    end
                    else if(C1[2]+C1[3]<=C1[6])begin
                        C2[6]<=C1[6];
                        C2[5]<=C1[2]+C1[3];
                        C2[4]<=C1[5];
                        C2[3]<=C1[4];
                        C2_union[6]<=C1_union[6];
                        C2_union[5]<=C1_union[3]|C1_union[2];
                        C2_union[4]<=C1_union[5];
                        C2_union[3]<=C1_union[4];
                        C_union_index[2]<=C_union_index[1]|6'b010000;

                        C_union_index[2][5]<=1;
                        if(C_union_index[1][6])
                            C_union_index[2][6]<=1;
                        if(C_union_index[1][5])
                            C_union_index[2][4]<=1;
                        if(C_union_index[1][4])
                            C_union_index[2][3]<=1;
                        C_union[3]<=6'b011111;
                    end
                    else begin
                        C2[6]<=C1[2]+C1[3];
                        C2[5]<=C1[6];
                        C2[4]<=C1[5];
                        C2[3]<=C1[4];
                        C2_union[6]<=C1_union[3]|C1_union[2];
                        C2_union[5]<=C1_union[6];
                        C2_union[4]<=C1_union[5];
                        C2_union[3]<=C1_union[4];
                        C_union_index[2][6]<=1;
                        if(C_union_index[1][6])
                            C_union_index[2][5]<=1;
                        if(C_union_index[1][5])
                            C_union_index[2][4]<=1;
                        if(C_union_index[1][4])
                            C_union_index[2][3]<=1;
                        C_union[3]<=6'b011111;
                    end
                    state<=13;
                end
            13: begin
                    if(C2[3]+C2[4]<=C2[5])begin
                        C3[6]<=C2[6];
                        C3[5]<=C2[5];
                        C3[4]<=C2[3]+C2[4];
                        //C3_union[4]<=1;
                        
                        C3_union[6]<=C2_union[6];
                        C3_union[5]<=C2_union[5];
                        C3_union[4]<=C2_union[4]|C2_union[3];
                        C_union_index[3][4]<=1;
                        if(C_union_index[2][6])
                            C_union_index[3][6]<=1;
                        if(C_union_index[2][5])
                            C_union_index[3][5]<=1;
                    end
                    else if(C2[3]+C2[4]<=C2[6])begin
                        C3[6]<=C2[6];
                        C3[5]<=C2[3]+C2[4];
                        C3[4]<=C2[5];
                        C3_union[6]<=C2_union[6];
                        C3_union[5]<=C2_union[4]|C2_union[3];
                        C3_union[4]<=C2_union[5];
                        C_union_index[3][5]<=1;
                        if(C_union_index[2][6])
                            C_union_index[3][6]<=1;
                        if(C_union_index[2][5])
                            C_union_index[3][4]<=1;
                    end
                    else begin
                        C3[6]<=C2[3]+C2[4];
                        C3[5]<=C2[6];
                        C3[4]<=C2[5];
                        C3_union[6]<=C2_union[4]|C2_union[3];
                        C3_union[5]<=C2_union[6];
                        C3_union[4]<=C2_union[5];
                        C_union_index[3][6]<=1;
                        if(C_union_index[2][6])
                            C_union_index[3][5]<=1;
                        if(C_union_index[2][5])
                            C_union_index[3][4]<=1;
                    end
                    
                    
                    
                    state<=6;
                end
            6:  begin
                    if(C3[5]+C3[4]<=C3[6])begin
                        C4[5]<=C3[5]+C3[4];
                        C4[6]<=C3[6];

                        C4_union[6]<=C3_union[6];
                        C4_union[5]<=C3_union[5]|C3_union[4];
                        C_union_index[4][5]<=1;
                        if(C_union_index[3][6])
                            C_union_index[4][6]<=1;
                    end
                    else begin
                        C4[5]<=C3[6];
                        C4[6]<=C3[5]+C3[4];
                        C4_union[6]<=C3_union[5]|C3_union[4];
                        C4_union[5]<=C3_union[6];
                        //C_union_index[4]<=C_union_index[3]|6'b100000;
                        C_union_index[4][6]<=1;
                        if(C_union_index[3][6])
                            C_union_index[4][5]<=1;
                    end
                    state<=7;
                end
            7:  begin
                    if(C4[6]>=C4[5])begin
                        for(i=1;i<7;i=i+1)begin
                            if(C4_union[6][i]==1)begin
                                case(seq_symbol[i])
                                    1:  begin
                                            HC1<=HC1<<1;
                                            HC1[0]<=0;
                                            M1[bit[1]]<=1;
                                            bit[1]<=bit[1]+1;
                                        end
                                    2:  begin
                                            HC2<=HC2<<1;
                                            HC2[0]<=0;
                                            M2[bit[2]]<=1;
                                            bit[2]<=bit[2]+1;
                                        end
                                    3:  begin
                                            HC3<=HC3<<1;
                                            HC3[0]<=0;
                                            M3[bit[3]]<=1;
                                            bit[3]<=bit[3]+1;
                                        end
                                    4:  begin
                                            HC4<=HC4<<1;
                                            HC4[0]<=0;
                                            M4[bit[4]]<=1;
                                            bit[4]<=bit[4]+1;
                                        end
                                    5:  begin
                                            HC5<=HC5<<1;
                                            HC5[0]<=0;
                                            M5[bit[5]]<=1;
                                            bit[5]<=bit[5]+1;
                                        end
                                    6:  begin
                                            HC6<=HC6<<1;
                                            HC6[0]<=0;
                                            M6[bit[6]]<=1;
                                            bit[6]<=bit[6]+1;
                                        end
                                endcase
                            end
                            if(C4_union[5][i]==1)begin
                                case(seq_symbol[i])
                                    1:  begin
                                            HC1<=HC1<<1;
                                            HC1[0]<=1;
                                            M1[bit[1]]<=1;
                                            bit[1]<=bit[1]+1;
                                        end
                                    2:  begin
                                            HC2<=HC2<<1;
                                            HC2[0]<=1;
                                            M2[bit[2]]<=1;
                                            bit[2]<=bit[2]+1;
                                        end
                                    3:  begin
                                            HC3<=HC3<<1;
                                            HC3[0]<=1;
                                            M3[bit[3]]<=1;
                                            bit[3]<=bit[3]+1;
                                        end
                                    4:  begin
                                            HC4<=HC4<<1;
                                            HC4[0]<=1;
                                            M4[bit[4]]<=1;
                                            bit[4]<=bit[4]+1;
                                        end
                                    5:  begin
                                            HC5<=HC5<<1;
                                            HC5[0]<=1;
                                            M5[bit[5]]<=1;
                                            bit[5]<=bit[5]+1;
                                        end
                                    6:  begin
                                            HC6<=HC6<<1;
                                            HC6[0]<=1;
                                            M6[bit[6]]<=1;
                                            bit[6]<=bit[6]+1;
                                        end
                                endcase
                            end
                        end
                    end
                    state<=8;
                end
            8:  begin
                    if(C3[5]>=C3[4])begin
                        for(i=1;i<7;i=i+1)begin
                            if(C3_union[5][i]==1)begin
                                case(seq_symbol[i])
                                    1:  begin
                                            HC1<=HC1<<1;
                                            HC1[0]<=0;
                                            M1[bit[1]]<=1;
                                            bit[1]<=bit[1]+1;
                                        end
                                    2:  begin
                                            HC2<=HC2<<1;
                                            HC2[0]<=0;
                                            M2[bit[2]]<=1;
                                            bit[2]<=bit[2]+1;
                                        end
                                    3:  begin
                                            HC3<=HC3<<1;
                                            HC3[0]<=0;
                                            M3[bit[3]]<=1;
                                            bit[3]<=bit[3]+1;
                                        end
                                    4:  begin
                                            HC4<=HC4<<1;
                                            HC4[0]<=0;
                                            M4[bit[4]]<=1;
                                            bit[4]<=bit[4]+1;
                                        end
                                    5:  begin
                                            HC5<=HC5<<1;
                                            HC5[0]<=0;
                                            M5[bit[5]]<=1;
                                            bit[5]<=bit[5]+1;
                                        end
                                    6:  begin
                                            HC6<=HC6<<1;
                                            HC6[0]<=0;
                                            M6[bit[6]]<=1;
                                            bit[6]<=bit[6]+1;
                                        end
                                endcase
                            end
                            if(C3_union[4][i]==1)begin
                                case(seq_symbol[i])
                                    1:  begin
                                            HC1<=HC1<<1;
                                            HC1[0]<=1;
                                            M1[bit[1]]<=1;
                                            bit[1]<=bit[1]+1;
                                        end
                                    2:  begin
                                            HC2<=HC2<<1;
                                            HC2[0]<=1;
                                            M2[bit[2]]<=1;
                                            bit[2]<=bit[2]+1;
                                        end
                                    3:  begin
                                            HC3<=HC3<<1;
                                            HC3[0]<=1;
                                            M3[bit[3]]<=1;
                                            bit[3]<=bit[3]+1;
                                        end
                                    4:  begin
                                            HC4<=HC4<<1;
                                            HC4[0]<=1;
                                            M4[bit[4]]<=1;
                                            bit[4]<=bit[4]+1;
                                        end
                                    5:  begin
                                            HC5<=HC5<<1;
                                            HC5[0]<=1;
                                            M5[bit[5]]<=1;
                                            bit[5]<=bit[5]+1;
                                        end
                                    6:  begin
                                            HC6<=HC6<<1;
                                            HC6[0]<=1;
                                            M6[bit[6]]<=1;
                                            bit[6]<=bit[6]+1;
                                        end
                                endcase
                            end
                        end
                    end
                    state<=9;
                end
            9:  begin
                    if(C2[4]>=C2[3])begin
                        for(i=1;i<7;i=i+1)begin
                            if(C2_union[4][i]==1)begin
                                case(seq_symbol[i])
                                    1:  begin
                                            HC1<=HC1<<1;
                                            HC1[0]<=0;
                                            M1[bit[1]]<=1;
                                            bit[1]<=bit[1]+1;
                                        end
                                    2:  begin
                                            HC2<=HC2<<1;
                                            HC2[0]<=0;
                                            M2[bit[2]]<=1;
                                            bit[2]<=bit[2]+1;
                                        end
                                    3:  begin
                                            HC3<=HC3<<1;
                                            HC3[0]<=0;
                                            M3[bit[3]]<=1;
                                            bit[3]<=bit[3]+1;
                                        end
                                    4:  begin
                                            HC4<=HC4<<1;
                                            HC4[0]<=0;
                                            M4[bit[4]]<=1;
                                            bit[4]<=bit[4]+1;
                                        end
                                    5:  begin
                                            HC5<=HC5<<1;
                                            HC5[0]<=0;
                                            M5[bit[5]]<=1;
                                            bit[5]<=bit[5]+1;
                                        end
                                    6:  begin
                                            HC6<=HC6<<1;
                                            HC6[0]<=0;
                                            M6[bit[6]]<=1;
                                            bit[6]<=bit[6]+1;
                                        end
                                endcase
                            end
                            if(C2_union[3][i]==1)begin
                                case(seq_symbol[i])
                                    1:  begin
                                            HC1<=HC1<<1;
                                            HC1[0]<=1;
                                            M1[bit[1]]<=1;
                                            bit[1]<=bit[1]+1;
                                        end
                                    2:  begin
                                            HC2<=HC2<<1;
                                            HC2[0]<=1;
                                            M2[bit[2]]<=1;
                                            bit[2]<=bit[2]+1;
                                        end
                                    3:  begin
                                            HC3<=HC3<<1;
                                            HC3[0]<=1;
                                            M3[bit[3]]<=1;
                                            bit[3]<=bit[3]+1;
                                        end
                                    4:  begin
                                            HC4<=HC4<<1;
                                            HC4[0]<=1;
                                            M4[bit[4]]<=1;
                                            bit[4]<=bit[4]+1;
                                        end
                                    5:  begin
                                            HC5<=HC5<<1;
                                            HC5[0]<=1;
                                            M5[bit[5]]<=1;
                                            bit[5]<=bit[5]+1;
                                        end
                                    6:  begin
                                            HC6<=HC6<<1;
                                            HC6[0]<=1;
                                            M6[bit[6]]<=1;
                                            bit[6]<=bit[6]+1;
                                        end
                                endcase
                            end
                        end
                    end
                    state<=10;
                end
            10: begin
                    if(C1[3]>=C1[2])begin
                        for(i=1;i<7;i=i+1)begin
                            if(C1_union[3][i]==1)begin
                                case(seq_symbol[i])
                                    1:  begin
                                            HC1<=HC1<<1;
                                            HC1[0]<=0;
                                            M1[bit[1]]<=1;
                                            bit[1]<=bit[1]+1;
                                        end
                                    2:  begin
                                            HC2<=HC2<<1;
                                            HC2[0]<=0;
                                            M2[bit[2]]<=1;
                                            bit[2]<=bit[2]+1;
                                        end
                                    3:  begin
                                            HC3<=HC3<<1;
                                            HC3[0]<=0;
                                            M3[bit[3]]<=1;
                                            bit[3]<=bit[3]+1;
                                        end
                                    4:  begin
                                            HC4<=HC4<<1;
                                            HC4[0]<=0;
                                            M4[bit[4]]<=1;
                                            bit[4]<=bit[4]+1;
                                        end
                                    5:  begin
                                            HC5<=HC5<<1;
                                            HC5[0]<=0;
                                            M5[bit[5]]<=1;
                                            bit[5]<=bit[5]+1;
                                        end
                                    6:  begin
                                            HC6<=HC6<<1;
                                            HC6[0]<=0;
                                            M6[bit[6]]<=1;
                                            bit[6]<=bit[6]+1;
                                        end
                                endcase
                            end
                            if(C1_union[2][i]==1)begin
                                case(seq_symbol[i])
                                    1:  begin
                                            HC1<=HC1<<1;
                                            HC1[0]<=1;
                                            M1[bit[1]]<=1;
                                            bit[1]<=bit[1]+1;
                                        end
                                    2:  begin
                                            HC2<=HC2<<1;
                                            HC2[0]<=1;
                                            M2[bit[2]]<=1;
                                            bit[2]<=bit[2]+1;
                                        end
                                    3:  begin
                                            HC3<=HC3<<1;
                                            HC3[0]<=1;
                                            M3[bit[3]]<=1;
                                            bit[3]<=bit[3]+1;
                                        end
                                    4:  begin
                                            HC4<=HC4<<1;
                                            HC4[0]<=1;
                                            M4[bit[4]]<=1;
                                            bit[4]<=bit[4]+1;
                                        end
                                    5:  begin
                                            HC5<=HC5<<1;
                                            HC5[0]<=1;
                                            M5[bit[5]]<=1;
                                            bit[5]<=bit[5]+1;
                                        end
                                    6:  begin
                                            HC6<=HC6<<1;
                                            HC6[0]<=1;
                                            M6[bit[6]]<=1;
                                            bit[6]<=bit[6]+1;
                                        end
                                endcase
                            end
                        end
                    end
                    state<=14;
                end
            14: begin
                    if(seq[2]>seq[1])begin
                        case(seq_symbol[2])
                            1:  begin
                                    HC1<=HC1<<1;
                                    HC1[0]<=0;
                                    M1[bit[1]]<=1;
                                    bit[1]<=bit[1]+1;
                                end
                            2:  begin
                                    HC2<=HC2<<1;
                                    HC2[0]<=0;
                                    M2[bit[2]]<=1;
                                    bit[2]<=bit[2]+1;
                                end
                            3:  begin
                                    HC3<=HC3<<1;
                                    HC3[0]<=0;
                                    M3[bit[3]]<=1;
                                    bit[3]<=bit[3]+1;
                                end
                            4:  begin
                                    HC4<=HC4<<1;
                                    HC4[0]<=0;
                                    M4[bit[4]]<=1;
                                    bit[4]<=bit[4]+1;
                                end
                            5:  begin
                                    HC5<=HC5<<1;
                                    HC5[0]<=0;
                                    M5[bit[5]]<=1;
                                    bit[5]<=bit[5]+1;
                                end
                            6:  begin
                                    HC6<=HC6<<1;
                                    HC6[0]<=0;
                                    M6[bit[6]]<=1;
                                    bit[6]<=bit[6]+1;
                                end
                        endcase
                            
                        case(seq_symbol[1])
                            1:  begin
                                    HC1<=HC1<<1;
                                    HC1[0]<=1;
                                    M1[bit[1]]<=1;
                                    bit[1]<=bit[1]+1;
                                end
                            2:  begin
                                    HC2<=HC2<<1;
                                    HC2[0]<=1;
                                    M2[bit[2]]<=1;
                                    bit[2]<=bit[2]+1;
                                end
                            3:  begin
                                    HC3<=HC3<<1;
                                    HC3[0]<=1;
                                    M3[bit[3]]<=1;
                                    bit[3]<=bit[3]+1;
                                end
                            4:  begin
                                    HC4<=HC4<<1;
                                    HC4[0]<=1;
                                    M4[bit[4]]<=1;
                                    bit[4]<=bit[4]+1;
                                end
                            5:  begin
                                    HC5<=HC5<<1;
                                    HC5[0]<=1;
                                    M5[bit[5]]<=1;
                                    bit[5]<=bit[5]+1;
                                end
                            6:  begin
                                    HC6<=HC6<<1;
                                    HC6[0]<=1;
                                    M6[bit[6]]<=1;
                                    bit[6]<=bit[6]+1;
                                end
                        endcase
                    end
                    state<=15;
                end
            15:  begin
                    CNT_valid<=1;
                    code_valid<=1;
                end

            
        endcase
    end


end


endmodule

