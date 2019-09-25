module labK;

reg a, b, c, flag, expect;

wire tmp, z1, z2, z;

not my_not1(expect0, 1);
not my_not2(expect1, 0);
not my_not_c(tmp, c);
and my_and1(z1, a, tmp);
and my_and2(z2, b, c);
or my_or(z, z1, z2);

initial
begin
  flag = $value$plusargs("a=%b", a);
  flag = $value$plusargs("b=%b", b);
  flag = $value$plusargs("c=%b", c);
  expect = z & 1;
  if(flag == "")
    $display("Some value(s) is missing");
  else
    if(z === expect)
      #10 $monitor("PASS: a=%b, b=%b, c=%b, z=%b", a, b, c, z);
    else
      #10 $monitor("FAIL: a=%b, b=%b, c=%b, z=%b", a, b, c, z);
  $finish;
end
endmodule
