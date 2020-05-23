module t_ALU;

   reg signed   [3:0] a, b, expect;
   reg [2:0]           clt;
   wire                ex;
   wire [3:0]          z;
   reg                 ok = 0, flag, tmp, zero;
   reg [1*7:0]         operator;

   ALU4 alu(z, ex, a, b, clt);

   initial
     begin
        repeat (10)
          begin
             a = $random;
             b = $random;
             tmp = $random % 2;
             flag = $value$plusargs("clt=%d", clt);

             if (tmp === 0) b = a;

             // The oracle: compute "expect" based on "op"
             if (clt === 3'b000) begin
                expect = a + b;
                operator = "+";
             end
             else if (clt === 3'b001) begin
                expect = a & b;
                operator = "&";
             end
             else if (clt === 3'b010) begin
                expect = a | b;
                operator = "|";
             end
             else if (clt === 3'b100) begin
                expect = a - b;
                operator = "-";
             end
             else if (clt === 3'b111) begin
                expect = (a < b) ? 1 : 0;
                operator = "<";
             end

             #5;

             // Compare the circuit's output with "expect"
             // and set "ok" accordingly
             ok = (expect === z) ? 1 : 0;
             zero = (expect === 0) ? 1 : 0;

             if (ok)
               #5 $display("PASS:  a=%b\n       b=%b\n     a%sb=%b\n    zero=%b\n",
                        a, b, operator, z, zero);
             else
               #5 $display("FAIL:  a=%b\n       b=%b\n     a%sb=%b\nexpected=%b\n    zero=%b\n",
                        a, b, operator, z, expect, zero);
          end
        $finish;
     end

endmodule // t_ALU
