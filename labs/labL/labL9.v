module labL ;

   reg   [31:0] a, b, expect;
   reg   [2:0] op;
   wire        ex;
   wire [31:0] z;
   reg         ok = 0, flag;
   reg   [1*7:0] operator;

   yAlu alu(z, ex, a, b, op);

   initial
     begin
        repeat (2)
          begin
             a = $random;
             b = $random;
             flag = $value$plusargs("op=%d", op);

             // The oracle: compute "expect" based on "op"
             if (op === 3'b000) begin
                expect = a & b;
                operator = "&";
             end
             else if (op === 3'b001) begin
                expect = a | b;
                operator = "|";
             end
             else if (op === 3'b010) begin
                expect = a + b;
                operator = "+";
             end
             else if (op === 3'b110) begin
                expect = a - b;
                operator = "-";
             end

             #1;

             // Compare the circuit's output with "expect"
             // and set "ok" accordingly
             ok = (expect === z) ? 1 : 0;

             if (ok)
               $display("PASS:  a=%b\n       b=%b\n     a%sb=%b\n",
                        a, b, operator, z);
             else
               $display("FAIL:  a=%b\n       b=%b\n     a%sb=%b\nexpected=%b\n",
                        a, b, operator, z, expect);
          end
        $finish;
     end

endmodule // LabL
