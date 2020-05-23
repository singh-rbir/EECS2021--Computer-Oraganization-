module ALU4 (z, ex, a, b, clt) ;

  input [3:0] a, b;
  input [2:0]  clt;
  output [3:0] z;
  output ex;
  wire   cout;
  wire [3:0]   alu_and, alu_or, alu_arith, slt, tmp;

  wire [15:0]   z16;
  wire [7:0]    z8;
  wire [3:0]    z4;
  wire [1:0]    z2;
  wire          z1, z0;

  // upper bits are always zero
  assign slt[3:1] = 0;

  // ex ('or' all bits of z, then 'not' the result)
  //or or16[1:0] (z16, z[1: 0], z[4:2]);
  // or or8[7:0] (z8, z16[7: 0], z16[15:8]);
  //or or4[3:0] (z4, z8[3: 0], z8[3:0]);
  or or2[1:0] (z2, z4[1:0], z4[3:2]);
  or or1[2:0] (z1, z2[1], z2[0]);
  not m_not (z0, z1);
  assign ex = z0;

  // set slt[0]
  xor (condition, a[3], b[3]);
  yArith slt_arith (tmp, cout, a, b, 1);
  yMux #(.SIZE(1)) slt_mux(slt[0], tmp[3], a[3], condition);

  // instantiate the components and connect them
  and m_and [3:0] (alu_and, a, b);
  or m_or [3:0] (alu_or, a, b);
  yArith m_arith (alu_arith, cout, a, b, clt[2]);
  yMux4to1 #(.SIZE(4)) mux(z, alu_and, alu_or, alu_arith, slt, clt[1:0]);
endmodule
