module labK;

reg a, b;   // without size means 1 bit
wire tmp, z;

not my_not(tmp, b);
and my_and(z, a, temp);

initial
begin
  #5 a = 1;
  #20 b = 1;
  $display("a=%b b=%b z=%b", a, b, z);
  $finish;
end

endmodule
