module yArith(z, cout, a, b, ctrl); // add if ctrl=0, subtract if ctrl=1 output [31:0] z;

output [31:0] z;
output cout;
input [31:0] a, b;
input ctrl;
wire[31:0] notB, tmp;
wire cin;

// instantiate the components and connect them
// Hint: about 4 lines of code
assign cin = ctrl;
not my_not[31:0] (notB, b);
yMux #(32) mux(tmp, b, notB, cin);
yAdder adder(z, cout, a, tmp, cin);

endmodule
