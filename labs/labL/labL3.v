module labL2;
reg[31:0] a, b, expect;
reg c, flag;

wire[31:0] z;
yMux #(32) my_mux(z, a, b, c);

initial
begin

  repeat (10)
    begin
      a = $random;
      b = $random;
      c = $random % 2;
      #1;

      if(c === 0)
        expect = a;
      else
        expect = b;

      // compare z with the expected output
      if(z === expect)
        #10 $display("PASS: a=%b, b=%b, c=%b, z=%b", a, b, c, z);
      else
        #20 $display("FAIL: a=%b, b=%b, c=%b, z=%b", a, b, c, z);

    end

  $finish;

end
endmodule
