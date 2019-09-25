module LabM;

reg[4:0] rs1, rs2, wn;
reg[31:0] wd;
wire[31:0] rd1, rd2;
reg w, clk, flag;
integer i;

rf myRF(rd1, rd2, rs1, rs2, wn, wd, clk, w);

initial
begin
  flag = $value$plusargs("w=%b", w);
  for(i = 0; i < 32; i = i + 1)
  begin
    clk = 0;
    wd = i * i;
    wn = i;
    clk = 1;
    #1;
  end

  repeat(10)
  begin
  #1;
    rs1 = $random;
    rs2 = $random;
    #10;
    $display("rs1=%b, rs2=%b, rd1=%b, rd2=%b", rs1, rs2, rd1, rd2);
  end

$finish;
end

endmodule
