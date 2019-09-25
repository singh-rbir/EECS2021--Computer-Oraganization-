module ff(q, d, clk, enable);
/****************************
An Edge-Triggerred Flip-flop 
Written by H. Roumani, 2008.
****************************/
output q;
input d, clk, enable;
reg q;

always @ (posedge clk)
  if (enable) q <= d; 

endmodule
