module yAdder (z, cout, a, b, cin) ;

   output [31:0] z;
   output        cout;
   input  [31:0] a, b;
   input         cin;
   wire   [31:0] in, out;

   yAdder1 mine [31:0] (z, out, a, b, in);

   assign in[0] = cin;

   genvar        i;
   generate
      for (i = 1; i < 32; i = i + 1) begin : asg
         assign in[i] = out[i-1];
      end
   endgenerate

   assign cout = out[31];

endmodule // yAdder
