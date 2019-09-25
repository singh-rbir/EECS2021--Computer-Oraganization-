module labK;

reg a, b, c;

wire not_output, and1_output, z1, z2, z;

not my_not_c(not_output, c);
and my_and1(z1, a, and1_output);
and my_and2(z2, b, c);
or my_or(z, z1, z2);
assign and1_output = not_output;

initial
begin
  a = 1; b = 0; c = 0;
  #10;
  $monitor("a=%b, b=%b, c=%b, z=%b", a, b, c, z);
  $finish;
end
endmodule
