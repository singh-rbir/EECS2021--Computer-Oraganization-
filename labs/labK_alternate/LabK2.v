module labK;

reg [31:0] x, y, z;

initial
begin
  #10 x = 5;
  //$display("%2d: x=%1d y=%1d z=%1d", $time, x, y, z);
  #10 y = x + 1;
  //$display("%2d: x=%1d y=%1d z=%1d", $time, x, y, z);
  #10 z = y + 1;
  //$display("%2d: x=%1d y=%1d z=%1d", $time, x, y, z);
  #1 $finish;
end

/*
initial
begin
  repeat(4)
    #7 x += 1;
end
*/

initial
  $monitor("%2d: x=%1d y=%1d z=%1d", $time, x, y, z);

always
  #7 x += 1;

endmodule
