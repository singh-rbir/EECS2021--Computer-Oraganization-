module LabL;

reg [31:0] expect, a, b;
reg cin;
wire[31:0] z;
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
        #1 $display("PASS");
      else
        #2 $display("FAIL");

      //...

    end
    $finish;
end
endmodule
