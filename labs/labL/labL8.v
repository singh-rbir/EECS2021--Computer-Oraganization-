module labL;

   reg  signed [31:0] a, b, expect;
   reg  signed        ctrl;
   wire signed [31:0] z;
   wire signed        cout;

   yArith arith(z, cout, a, b, ctrl);

   initial
     begin
        repeat (6)
          begin
             a = $random;
             b = $random;
             ctrl = $random % 2;

             expect = ctrl ? (a - b) : (a + b);

             #1; // wait for z
             if (expect === z)
               $display("PASS: a=%d \n      b=%d \n   ctrl=%b \n      z=%d \n expect=%d",
                        a, b, ctrl, z, expect);
             else
               $display("FAIL: a=%d \n      b=%d \n   ctrl=%b \n      z=%d \n expect=%d",
                        a, b, ctrl, z, expect);

          end
        $finish;
     end

endmodule // LabL
