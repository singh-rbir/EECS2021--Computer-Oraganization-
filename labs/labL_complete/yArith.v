module yArith (z, cout, a, b, ctrl);
   // add if ctrl=0, subtract if ctrl=1
   output [3:0] z;
   output cout;
   input  [3:0] a, b;
   input  [2:0] ctrl;
   wire   [3:0] notB, tmp;
   wire  [3:0] cin;

   // instantiate the components and connect them
   assign cin = ctrl;
   not my_not [3:0] (notB, b);
   yMux #(4) mux(tmp, b, notB, cin);
   yAdder adder(z, cout, a, tmp, cin);

endmodule // yArith
