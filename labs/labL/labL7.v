module LabL;

reg signed [31:0] expect, a, b;
reg cin;
wire signed [31:0] z;
wire cout;
reg ok;

yAdder my_adder(z, cout, a, b, cin);

initial
begin

  repeat (3)
    begin
      a = $random;
      b = $random;
      cin = 0;

      //...
      expect = a + b + cin;
      #1;
      ok = 0;
      if (expect === z)
               $display("PASS: a=%b \n      b=%b \n    cin=%b \n      z=%b \n expect=%b",
                        a, b, cin, z, expect);
             else
               $display("FAIL: a=%b \n      b=%b \n    cin=%b \n      z=%b \n expect=%b",
                        a, b, cin, z, expect);
      //...

    end
    $finish;
end
endmodule
