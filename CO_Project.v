module Mux (x,y,sel,z);

input x,y,sel;
output reg z;

always@(x or y or sel)
begin

if(sel == 0)
begin
z=x;
end

else if(sel == 1)
begin
z=y;
end

else
begin
z=1'bx;
end

end
endmodule

module RegFile (rr1,rr2,wr,clk,write_enable,rd1,rd2,writeData,Resultt,selector);

input [4:0] rr1,rr2,wr;
input clk,write_enable,selector;
input [31:0] writeData,Resultt;
output [31:0] rd1,rd2;
reg [31:0] RF [0:31];

assign rd1 = RF[rr1];
assign rd2 = RF[rr2];

always @(posedge clk)
begin

if(write_enable)
begin
Mux mymux (x,y,sel,z);
reg [31:0] x,y;
reg sel;
wire [31:0] z;
x <= writeData;
y <= Resultt;
sel <= selector;
RF[wr] <= z;
end

end

endmodule

module ALU (A,B,op,shift_amt,Result,overflow);


input signed [31:0] A,B ;
input [3:0] op;
input [4:0] shift_amt;
output reg signed [31:0] Result;
output reg overflow;
wire [31:0] Neg_B;


assign Neg_B = -B;


always@(op or A or B)
begin
case(op)

//add
0 : begin
    Result = A+B;
    overflow = (A[31]==B[31] && Result[31]!=A[31])? 1:0 ;
    end


//sub
1 : begin
    Result = A-B;
    overflow = (A[31] == Neg_B[31]  && Result[31]!=A[31])? 1:0;
    end

//and
2 : Result <= A&B;

//or
3 : Result <= A|B ;

//sll
4 : Result <= A << shift_amt ;

//srl
5 : Result <= A >> shift_amt ;

//sra
6 : Result <= A >>> shift_amt;

//Greaterthan
7 : Result <= (A>B) ? 1:0 ;

//less than 
8 : Result <= (A<B) ? 1:0 ;


endcase
end
endmodule
module Test_ALU ;

reg [4:0] rr1,rr2,wr;
reg clk,write_enable,selector;
reg [31:0] writeData,Resultt;
wire [31:0] rd1,rd2;
RegFile MyRegFile (rr1,rr2,wr,clk,write_enable,rd1,rd2,writeData,Resultt,selector);

reg [31:0] A,B;
reg [3:0] op;
reg [4:0] shift_amt;
wire [31:0] Result;
wire overflow;

ALU MyAlu (A,B,op,shift_amt,Result,overflow);


initial 
begin
write_enable <=1;
selector <=0;
wr <= 1;
always @ (!selector,posedge clk)
begin 
writeData <= 32'bx;
wr <= wr+1;
if (wr == 32)
selector <= 1;
end 

//add
$display ("Addition");
$monitor(" A=%d , B=%d , A+B=%d , overflow=%d " , A,B,rd1,overflow); 
rr1 <= 1;
rr2 <= 2;

op <= 0;
A <= rd1;  
B <= rd2;
wr <= 1;
Resultt <= Result;
rr1 <= wr;


#5
A = (2**31)-1 ;
B= 5;

//sub
#5
$display ("\nsubtraction");
$monitor(" A=%d , B=%d , A-B=%d , overflow=%d " , A,B,Result,overflow); 

op <=1;
A=300;
B=200;

#5
A= -(2**31);
B= 100;

//and
#5
$display ("\nand");
$monitor(" A=%b , B=%b , A & B=%b " , A,B,Result);

op <=2;
A=32'b01010100101100101001010110111111;
B=32'b11111111111111100010110100101010;

//or
#5
$display ("\nor");
$monitor(" A=%b , B=%b , A | B =%b " , A,B,Result);

op <=3;
A=32'b01010100101100101001010110111111;
B=32'b11111111111111100010110100101010;

//sll
#5
$display ("\nshift left");
$monitor(" A=%b ,shift_amt=%d, Result =%b " ,A,shift_amt,Result);

op <=4;
A=32'b11111111111111111111111111111111;
shift_amt = 5;


//srl
#5
$display ("\nshift right logical,");
$monitor(" A= %b ,shift_amt =%d, Result =%b " ,A,shift_amt,Result);

op <=5;
A=32'b11111111111111111111111111111111;
shift_amt = 5;


//sra
#5
$display ("\nshift right arithmetic");
$monitor(" A= %b ,shift_amt =%d, Result =%b " ,A,shift_amt,Result);

op <=6;
A=32'b11111111111111111111111111110000;
shift_amt = 5;

//greater_than
#5
$display ("\ngreater_than(Result=1 if A>B)n");
$monitor(" A= %d , B =%d, Result =%d " ,A,B,Result);

op <=7;
A=5555;
B=999999;

//less_than
#5
$display ("\nless_than (Result=1 if A<B)");
$monitor(" A= %d , B=%d, Result=%d " ,A,B,Result);

op <=8;
A=-13;
B=20;

end


endmodule