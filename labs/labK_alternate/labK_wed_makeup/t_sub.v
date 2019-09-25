module t_sub;

reg[3:0] a, b;
reg cin;
output [3:0] S;
output cout;

sub4 mine(S, cout, a, b, cin);

initial
begin
  a = 0;
  b = 0;
  repeat(7)
  begin
    a = a + 1;
    b = b + 2;
    #5;
    $display("time:%d A:%d  B:%d  S:%d  cout:%d", $time, a, b, S, cout);

  end
  $finish;
end
endmodule
