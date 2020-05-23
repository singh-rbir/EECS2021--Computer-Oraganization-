module yAdder (z, cout, a, b, cin) ;

   output [3:0] z;
   output        cout;
   input  [3:0] a, b;
   input         cin;
   wire   [3:0] in, out;

   yAdder1 mine [3:0] (z, out, a, b, in);

   assign in[0] = cin;

   genvar        i;
   generate
      for (i = 1; i < 4; i = i + 1) begin : asg
         assign in[i] = out[i-1];
      end
   endgenerate

   assign cout = out[3];

endmodule // yAdder
