module labK;

reg a, b, cin, flag;

wire my_xor1, my_xor2, my_and1, my_and2, z, cout;

xor myXor1(my_xor1, a, b);
and myAnd1(my_and1, a, b);
xor myXor2(z, my_xor1, cin);
and myAnd2(myAnd2, cin, my_xor1);
or myOr(cout, my_and1, my_and2);


initial
begin
  flag = $value$plusargs("a=%b", a);
  flag = $value$plusargs("b=%b", b);
  flag = $value$plusargs("c=%b", cin);
  if(flag == "")
    $display("Some value(s) is missing");
  else
    #10 $monitor("a=%b, b=%b, cin=%b, z=%b, cout=%b", a, b, cin, z, cout);

  $finish;
end
endmodule
