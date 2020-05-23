//Name: Rajanbir Singh

//Module: cfulladder
//This module subtracts 1-bit 2 binary numbers a and b

module cfulladder(S, Cout, a, b, c);

input a, b, c;
wire tmp1, tmp2, tmp3, tmp4, NotTmp1, NotA;
reg S1, Cout1;
output S, Cout;

/*
xor  my_or(tmp1, a, b);
not my_not(NotTmp1, tmp1);
xor my_xor(S, tmp1, c);
not my_not1(NotA, a);
and my_and(tmp4, NotA, b);
and my_and2(tmp3, NotTmp1, c);
or my_or1(Cout, tmp3, tmp4);
*/

always
begin
#1 S1 = (a^b)^c;
end
always
begin
#1 Cout1 = ((~a)&b) | (~(a^b)&c);
end
assign S= S1;
assign Cout=Cout1;

endmodule

//Module: sub4------------------------------------------
//This module calls cfulladder 4 times to represent 4 bits, and returns it to the t_sub module. Also it takes care of the carryout as expected.

module sub4(S, Cout, a, b, c);

input [3:0] a, b;
input c;
output [3:0] S;
output Cout;
wire [3:0] in, out;

cfulladder my_adder[3:0](S, out, a, b, in);

assign in[0] = c;
assign in[1] = out[0];
assign in[2] = out[1];
assign in[3] = out[2];
assign Cout = in[3];

endmodule


//Module: t_sub-------------------------------------------------
//This module repeats 7 times and delays by 5 units, displaying registers and wires in decimal format. This module also calls sub4 which initiaties the 4 bit subtactor.

module t_sub;
reg [3:0] a, b;
reg c;
reg S1, neg;
wire [3:0] S, out;
wire Cout;

sub4 test(S, Cout, a, b, c );

//neg = 4'hf;
//xor (S1, S[0], neg);
//assign out[0]=S1;


initial
begin
	a=0;
	b=0;
	c=0;
	repeat(7)
	begin

		a = a+1;
		b = b+2;

		#5;
		//S1=neg^S1[0];
		//S1=S^-1;
		//S1=S1+1;
		$display("Time= %1d A=%d B=%d S=%d Cout=%d", $time, a, b, S, Cout);
	end
$finish;
end
endmodule
