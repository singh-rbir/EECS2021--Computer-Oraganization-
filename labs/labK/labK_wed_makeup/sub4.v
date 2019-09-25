module sub4(S, cout, a, b, cin);

input [3:0] a,b;
input cin;
output [3:0] S;
output cout;
wire [3:0] in, out;

cfulladder my_adder[3:0](S,cout,a,b,cin);

assign in[0] = cin;
assign in[1] = out[0];
assign in[2] = out[1];
assign in[3] = out[2];
assign cout = in[3];

endmodule
/*
module sub4(S, cout, a, b, cin);

input [3:0] a, b;
input cin;
output [3:0] S;
output cout;


cfulladder mine1(S[3], cout, a[3], b[3], cin);
cfulladder mine2(S[2], cout, a[2], b[2], cin);
cfulladder mine3(S[1], cout, a[1], b[1], cin);
cfulladder mine4(S[0], cout, a[0], b[0], cin);

cfulladder mine[3:0](S, cout, a, b, cin);


endmodule
*/
