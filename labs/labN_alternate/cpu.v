module yMux1(z, a, b, c);
   output z;
   input  a, b, c;
   wire   notC, upper, lower;

   not my_not(notC, c);
   and upperAnd(upper, a, notC);
   and lowerAnd(lower, c, b);
   or my_or(z, upper, lower);
endmodule // yMux1

module yMux(z, a, b, c);
   parameter SIZE = 2;
   output [SIZE-1:0] z;
   input  [SIZE-1:0] a, b;
   input  c;

   yMux1 mine[SIZE-1:0](z, a, b, c);
endmodule // yMux

module yMux4to1(z, a0, a1, a2, a3, c);
   parameter SIZE = 2;
   output [SIZE-1:0] z;
   input  [SIZE-1:0] a0, a1, a2, a3;
   input  [1:0] c;
   wire   [SIZE-1:0] zLo, zHi;

   yMux #(SIZE) lo(zLo, a0, a1, c[0]);
   yMux #(SIZE) hi(zHi, a2, a3, c[0]);
   yMux #(SIZE) final(z, zLo, zHi, c[1]);
endmodule // yMux4to1

module yAdder1 (z, cout, a, b, cin) ;
   output z, cout;
   input  a, b, cin;

   xor left_xor(tmp, a, b);
   xor right_xor(z, cin, tmp);
   and left_and(outL, a, b);
   and right_and(outR, tmp, cin);
   or my_or(cout, outR, outL);
endmodule // yAdder1

module yAdder (z, cout, a, b, cin) ;
   output [31:0] z;
   output        cout;
   input  [31:0] a, b;
   input         cin;
   wire   [31:0] in, out;

   yAdder1 mine [31:0] (z, out, a, b, in);

   assign in[0] = cin;

   genvar        i;
   generate
      for (i = 1; i < 32; i = i + 1) begin : asg
         assign in[i] = out[i-1];
      end
   endgenerate

   assign cout = out[31];
endmodule // yAdder

module yArith (z, cout, a, b, ctrl) ;
   // add if ctrl=0, subtract if ctrl=1
   output [31:0] z;
   output cout;
   input  [31:0] a, b;
   input  ctrl;
   wire   [31:0] notB, tmp;
   wire   cin;

   // instantiate the components and connect them
   assign cin = ctrl;
   not my_not [31:0] (notB, b);
   yMux #(32) mux(tmp, b, notB, cin);
   yAdder adder(z, cout, a, tmp, cin);
endmodule // yArith

module yAlu (z, ex, a, b, op) ;
   input [31:0] a, b;
   input [2:0]  op;
   output [31:0] z;
   output        ex;
   wire          cout;
   wire [31:0]   alu_and, alu_or, alu_arith, slt, tmp;

   wire [15:0]   z16;
   wire [7:0]    z8;
   wire [3:0]    z4;
   wire [1:0]    z2;
   wire          z1, z0;

   // upper bits are always zero
   assign slt[31:1] = 0;

   // ex ('or' all bits of z, then 'not' the result)
   or or16[15:0] (z16, z[15: 0], z[31:16]);
   or or8[7:0] (z8, z16[7: 0], z16[15:8]);
   or or4[3:0] (z4, z8[3: 0], z8[7:4]);
   or or2[1:0] (z2, z4[1:0], z4[3:2]);
   or or1[15:0] (z1, z2[1], z2[0]);
   not m_not (z0, z1);
   assign ex = z0;

   // set slt[0]
   xor (condition, a[31], b[31]);
   yArith slt_arith (tmp, cout, a, b, 1'd1);
   yMux #(.SIZE(1)) slt_mux(slt[0], tmp[31], a[31], condition);

   // instantiate the components and connect them
   and m_and [31:0] (alu_and, a, b);
   or m_or [31:0] (alu_or, a, b);
   yArith m_arith (alu_arith, cout, a, b, op[2]);
   yMux4to1 #(.SIZE(32)) mux(z, alu_and, alu_or, alu_arith, slt, op[1:0]);
endmodule // yAlu

module yIF (ins, PCp4, PCin, clk) ;
   output [31:0] ins, PCp4;
   input  [31:0] PCin;
   input  clk;
   wire   [31:0] pcRegOut;
   wire   ex;
   reg    [31:0] memIn = 0;

   register #(32) pcReg(pcRegOut, PCin, clk, 1'd1);
   yAlu alu(PCp4, ex, 4, pcRegOut, 3'b010);
   mem memory(ins, pcRegOut, memIn, clk, 1'd1, 1'd0);
endmodule // yIF

module yID (rd1, rd2, imm, jTarget, ins, wd, RegDst, RegWrite, clk) ;
   output [31:0] rd1, rd2, imm;
   output [25:0] jTarget;
   input [31:0]  ins, wd;
   input         RegDst, RegWrite, clk;
   wire   [4:0] rn1, rn2, wn;
   wire [15:0]   zeros, ones;
   assign zeros[15:0] = 16'd0;
   assign ones[15:0] = 16'd1;

   assign rn1 = ins[25:21];
   assign rn2 = ins[20:16];
   yMux #(5) mux(wn, rn2, ins[15:11], RegDst);

   assign imm[15:0] = ins[15:0];
   yMux #(16) se(imm[31:16], zeros, ones, ins[15]);

   assign jTarget = ins[25:0];

   rf regfile(rd1, rd2, rn1, rn2, wn, wd, clk, RegWrite);
endmodule // yID

module yEX (z, zero, rd1, rd2, imm, op, ALUSrc) ;
   output [31:0] z;
   output        zero;
   input [31:0]  rd1, rd2, imm;
   input  [2:0] op;
   input  ALUSrc;
   wire   [31:0] b;

   yMux #(32) mux(b, rd2, imm, ALUSrc);
   yAlu alu(z, zero, rd1, b, op);
endmodule // yEX

module yDM(memOut, exeOut, rd2, clk, MemRead, MemWrite) ;
   output [31:0] memOut;
   input [31:0]  exeOut, rd2;
   input         clk, MemRead, MemWrite;

   mem memory(memOut, exeOut, rd2, clk, MemRead, MemWrite);
endmodule // yDM

module yWB(wb, exeOut, memOut, Mem2Reg) ;
   output [31:0] wb;
   input [31:0]  exeOut, memOut;
   input         Mem2Reg;

   yMux #(32) mux(wb, exeOut, memOut, Mem2Reg);
endmodule // yWB


module yPC(PCin, PCp4,INT,entryPoint,imm,jTarget,zero,branch,jump);
output [31:0] PCin;
input [31:0] PCp4, entryPoint, imm;
input [25:0] jTarget;
input INT, zero, branch, jump;

wire [31:0] immX4, bTarget, choiceA, choiceB, choiceC;
wire doBranch, zf;

assign immX4[31:2] = imm[29:0];
assign immX4[1:0] = 2'b00;

yAlu myALU(bTarget, zf, PCp4, immX4, 3'b010);
and (doBranch, branch, zero);
yMux #(32) mux1(choiceA, PCp4, bTarget, doBranch);

yMux #(32) mux2(choiceB, choiceA, {PCp4[31:28],jTarget[25:0],2'b00}, jump);

yMux #(32) mux3(choiceC, choiceB, entryPoint, INT);
assign PCin = choiceC;



endmodule // yPC

module yC1(rtype, lw, sw, jump, branch, opCode);
output rtype, lw, sw, jump, branch;
input [5:0] opCode;
wire not5, not4, not3, not2, not1, not0;

not (not5, opCode[5]);
not (not4, opCode[4]);
not (not3, opCode[3]);
not (not2, opCode[2]);
not (not1, opCode[1]);
not (not0, opCode[0]);

and (lw, opCode[5], not4, not3, not2, opCode[1], opCode[0]); //lw 100011
and (sw, opCode[5], not4, opCode[3], not2, opCode[1], opCode[0]); //sw 101011
and (jump, not5, not4, not3, not2, opCode[1], not0); //j 000010
and (branch, not5, not4, not3, opCode[2], not1, not0); // beq 000100
and (rtype, not5, not4, not3, not2, not1, not0); // rtype 000000

endmodule // yC1



module yC2(RegDst, ALUSrc, RegWrite, Mem2Reg, MemRead, MemWrite, rtype, lw, sw, branch);
output RegDst, ALUSrc, RegWrite, Mem2Reg, MemRead, MemWrite;
input rtype, lw, sw, branch;

assign RegDst = rtype;
nor (ALUSrc, rtype, branch);
nor (RegWrite, sw, branch);
assign Mem2Reg = lw;
assign MemRead = lw;
assign MemWrite = sw;

endmodule // yC2

module yC3(ALUop, rtype, branch);
output [1:0] ALUop;
input rtype, branch;

assign ALUop[0] = branch;
assign ALUop[1] = rtype;

endmodule // yC3

module yC4(op, ALUop, fnCode);
output [2:0] op;
input [5:0] fnCode;
input [1:0] ALUop;
wire upperAnd, invertF2, invertOp1, leftOr;

or left(leftOr, fnCode[0], fnCode[3]);
and upperAnd(upperAnd, ALUop[1], fnCode[1]);
or rightUpperOr(op[2], ALUop[0], upperAnd);
and lowerAnd(op[0], ALUop[1], leftOr);
not invertOp1(invertOp1, ALUop[1]);
not invertF2(invertF2, fnCode[2]);
or rightLowerOr(op[1], invertOp1, invertF2);

endmodule // yC4

module yChip(ins, z, PC, wb, entryPoint, INT, clk);
output [31:0] ins, z, PC, wb;
input [31:0] entryPoint;
input INT, clk;

wire [2:0] op;
wire [31:0] jTarget;
wire [31:0] branch;
wire [6:0] opCode;
wire zero, isbranch, isjump, isStype, isRtype, isItype, isLw;
wire RegWrite, ALUSrc, Mem2Reg, MemRead, MemWrite;
wire [2:0] funct3;
wire [1:0] ALUop;
wire [31:0] wd, rd1, rd2, imm, PCp4, z, memOut, PCin;

yIF myIF(ins, PC, PCp4, PCin, clk);
yID myID(rd1, rd2, imm, jTarget, branch, ins, wd, RegWrite, clk);
yEX myEx(z, zero, rd1, rd2, imm, op, ALUSrc);
yDM myDM(memOut, z, rd2, clk, MemRead, MemWrite);
yWB myWB(wb, z, memOut, Mem2Reg);
assign wd = wb;
yPC myPC(PCin, PC, PCp4, INT, entryPoint, branch, jTarget, zero, isbranch, isjump);
assign opCode = ins[6:0];
assign funct3 = ins[14:12];
yC1 myC1(isStype, isRtype, isItype, isLw, isjump, isbranch,opCode);
yC2 myC2(RegWrite, ALUSrc, MemRead, MemWrite, Mem2Reg, isStype, isRtype, isItype, isLw, isjump, isbranch);
yC3 myC3(ALUop, isRtype, isbranch);
yC4 myC4(op, ALUop, funct3);



/* ------------- Vish's yChip-------------------------

module yChip(ins, rd2, wb, entryPoint, INT, clk);
output [31:0] ins, rd2, wb;
input [31:0] entryPoint;
input INT, clk;

wire [31:0] PCin;

wire ALUSrc, MemRead, MemWrite, Mem2Reg, RegDst, RegWrite, branch, jump;
wire [2:0]  op;
wire [31:0] wd, rd1, imm, PCp4, z, memOut;
wire [25:0] jTarget;
wire zero;
wire [5:0] opCode, fnCode;
wire [1:0] ALUop;


yIF myIF(ins, PCp4, PCin, clk);
yID myID(rd1, rd2, imm, jTarget, ins, wd, RegDst, RegWrite, clk);
yEX myEx(z, zero, rd1, rd2, imm, op, ALUSrc);
yDM myDM(memOut, z, rd2, clk, MemRead, MemWrite);
yWB myWB(wb, z, memOut, Mem2Reg);
assign wd = wb;
yPC myPC(PCin, PCp4,INT,entryPoint,imm,jTarget,zero,branch,jump);
assign opCode = ins[31:26];
yC1 myC1(rtype, lw, sw, jump, branch, opCode);
yC2 myC2(RegDst, ALUSrc, RegWrite, Mem2Reg, MemRead, MemWrite, rtype, lw, sw, branch);
assign fnCode = ins[5:0];
yC3 myC3(ALUop, rtype, branch);
yC4 myC4(op, ALUop, fnCode);

*/

endmodule //yChips
