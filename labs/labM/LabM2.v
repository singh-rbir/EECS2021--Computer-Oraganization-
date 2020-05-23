module LabM;

reg [31:0] d;
reg clk, enable, flag, e;
wire [31:0] z;

register #(32) mine(z, d, clk, enable);

initial
begin
  clk = 0;
  flag = $value$plusargs("enable=%b", enable);
  repeat (20)
  begin
    #2 d = $random;
  end

$finish;
end

always
begin
  #5 clk = ~clk;
end

always
#1
begin
  $monitor("%5d: clk=%b,d=%d,z=%d,expect=%d", $time,clk,d,z, e);
  if(clk === 1)
    e = z;
end

endmodule
