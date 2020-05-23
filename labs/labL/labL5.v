module labL;
reg a, b, cin;
reg [1:0] sum;
wire z, cout;
yAdder1 my_adder(z, cout, a, b, cin);

initial
begin

  for(a = 0; a < 2; a = a + 1)
    for(b = 0; b < 2; b = b + 1)
      for(cin = 0; cin < 2; cin = cin + 1)
        begin
          sum = a + b + cin;
          #1
          if(sum[1] !== cout || sum[0] !== z)
            $display("FAIL: sum:%b", sum);

        end
  $finish;

end
endmodule
