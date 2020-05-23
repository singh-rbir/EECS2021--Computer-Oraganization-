//----------------------------------------ALU-----------------------------------
module yAlu(z, ex, a, b, op);
	input [31:0] a, b;
	input [2:0] op;
	output [31:0] z;
	output ex;
	wire [31:0] andi, ori, arith, sub, slt;
	wire condition;
	wire [15:0] z16;
	wire [7:0]  z8;
	wire [3:0]  z4;
	wire [1:0]  z2;
	wire z1;
	assign slt[31:1] = 0;
	//and--------------------------------
	and myAnd[31:0](andi, a, b);
	//or---------------------------------
	or  myOr[31:0](ori, a, b);
	//(+-)------------------------------
	yArith myArith(arith,null, a, b, op[2]);

	//slt------------------------------
	xor myXor (condition, a[31], b[31]);
	yArith sltArith(sub,null, a, b, 1'b1);
	yMux1  sltMux (slt[0], sub[31], a[31], condition);
	//---------------------------------
	//chosing result
	yMux4to1 #(32) myMux (z, andi, ori, arith, slt, op[1:0]);

	//Ex-------------------------------
	or or16[15:0] (z16, z[15:0], z[31:16]);
	or or8[7:0]  (z8, z16[7:0], z16[15:8]);
	or or4[3:0] (z4, z8[3:0], z8[7:4]);
	or or2[1:0]  (z2, z4[1:0], z4[3:2]);
	or or1 (z1, z2[0:0], z2[1:1]);
	not noting(ex, z1);
endmodule

//--------------------------------------------------------------------------------------
//---------------------------------------- MUX1  ---------------------------------------
module yMux1(z, a, b, c);
	output z;
	input a, b, c;
	wire notC, upper, lower;
	not my_not(notC, c);
	and upperAnd(upper, a, notC);
	and lowerAnd(lower, c, b);
	or my_or(z, upper, lower);
endmodule

//---------------------------------------------------------------------------------------
//--------------------------------------- MUX  ------------------------------------------
module yMux(z, a, b, c);
	parameter SIZE = 2;
	output [SIZE-1:0] z;
	input [SIZE-1:0] a, b;
	input c;
	yMux1 mine[SIZE-1:0](z, a, b, c);
endmodule

//---------------------------------------------------------------------------------------
//--------------------------------------MUX4to1------------------------------------------
module yMux4to1(z,a0,a1,a2,a3, c);
	parameter SIZE = 2;
	output [SIZE-1:0] z;
	input [SIZE-1:0] a0, a1, a2, a3;
	input [1:0] c;
	wire [SIZE-1:0] zLo, zHi;
	yMux #(SIZE) lo(zLo, a0, a1, c[0]);
	yMux #(SIZE) hi(zHi, a2, a3, c[0]);
	yMux #(SIZE) final(z, zLo, zHi, c[1]);
endmodule

//---------------------------------------------------------------------------------------
//-------------------------------------Adder1--------------------------------------------
module yAdder1(z, cout, a, b, cin);
	output z, cout;
	input a, b, cin;
	xor left_xor(tmp, a, b);
	xor right_xor(z, cin, tmp);
	and left_and(outL, a, b);
	and right_and(outR, tmp, cin);
	or my_or(cout, outR, outL);
endmodule

//---------------------------------------------------------------------------------------
//----------------------------------- Adder----------------------------------------------
module yAdder(z, cout, a, b, cin);
	output [31:0] z;
	output cout;
	input [31:0] a, b;
	input cin;
	wire[31:0] in, out;
	yAdder1 mine[31:0](z, out, a, b, in);
	assign in[0] = cin;
	assign in[31:1] = out[30:0];
	assign cout = out[31];
endmodule

//--------------------------------------------------------------------------------------------
//--------------------------------------Arith ------------------------------------------------
module yArith(z, cout, a, b, ctrl);

//add if ctrl=0, subtract if ctrl=1
	output [31:0] z;
	output cout;
	input [31:0] a, b;
	input ctrl;
	wire[31:0] notB, tmp;
	wire cin;
	assign cin = ctrl;
	not myNot[31:0](notB, b);
	yMux #(32) mymux(tmp, b, notB, cin);
	yAdder myadder(z,cout, a ,tmp , cin);

endmodule

//--------------------------------------------------------------------------------------------
//-------------------------------------yEX---------------------------------------------------

module yEX(z, zero, rd1, rd2, imm, op, ALUSrc);
	output [31:0] z;
	output zero;
	input [31:0] rd1, rd2, imm;
	input [2:0] op;
	input ALUSrc;
	wire [31:0]b , a;
	wire ex;
	yMux #(32) mux_two(b ,  rd2, imm, ALUSrc);
	yAlu  myAlu(z, zero,rd1, b, op);
endmodule
//--------------------------------------------------------------------------------------------
//-------------------------------------yID----------------------------------------------------
module yID(rd1, rd2, imm, jTarget, ins, wd, RegDst, RegWrite, clk);
	output [31:0] rd1, rd2, imm;        					// rs and rt and immediate
	output [25:0] jTarget; 		    					// jump
	input [31:0] ins, wd; 		     					// wd = value need to be written on rd and ins is instruction where rd id ins[20:16] or ins[15:11]
	input RegDst, RegWrite, clk; 	    			 		// regDst decide type of ins and regWrite allow to write and clk is clock
	wire [4:0] rn1, rn2, rn3, wn;
	assign rn1 = ins[25:21];
	assign rn2 = ins[20:16];
	assign rn3 = ins[15:11];
	assign jTarget = ins[25:0];
	assign imm[15:0] = ins[15:0];
	yMux #(5) myMux(wn, rn2, rn3, RegDst);
	rf 	   myRf(rd1, rd2, rn1, rn2, wn, wd, clk, RegWrite);
	yMux #(16) se(imm[31:16], 16'b0, 16'hffff, ins[15]);
endmodule
//--------------------------------------------------------------------------------------------
//--------------------------------------yIF---------------------------------------------------
module yIF(ins, PCp4, PCin, clk);

output [31:0] ins, PC, PCp4;
input [31:0] PCin;
input clk;
wire zero;
wire read, write, enable;
wire [31:0] a, memIn;
wire [2:0] op;
register #(32) pcReg(PC, PCin, clk, enable);
mem insMem(ins, PC, memIn, clk, read, write);
yAlu myAlu(PCp4, zero, a, PC, op);
assign enable = 1'b1;
assign a = 32'h0004;
assign op = 3'b010;
assign read = 1'b1;
assign write = 1'b0;

  /*
	output [31:0] ins, PCp4;
	input [31:0] PCin;
	input clk;
	wire [31:0] pcOut;
	register #(32) pc(pcOut, PCin, clk, 1'b1);
	yAlu myAlu(PCp4, null, pcOut, 32'd4, 3'b010);
	mem myMem(ins, pcOut, 32'b0, clk, 1'b1, 1'b0);
  */
endmodule
//--------------------------------------------------------------------------------------------
//-------------------------------------yDM----------------------------------------------------
module yDM(memOut, exeOut, rd2, clk, MemRead, MemWrite);
	output [31:0] memOut;
	input [31:0] exeOut, rd2;
	input clk, MemRead, MemWrite;
	mem DM(memOut, exeOut, rd2, clk, MemRead, MemWrite);
endmodule
//--------------------------------------------------------------------------------------------
//-------------------------------------yWB----------------------------------------------------
module yWB(wb, exeOut, memOut, Mem2Reg);
	output [31:0] wb;
	input [31:0] exeOut, memOut;
	input Mem2Reg;
	yMux #(32) WB(wb, exeOut, memOut, Mem2Reg);
endmodule
//------------------------------------------------------------------------------------------------
//-------------------------------------yPC--------------------------------------------------------

module yPC(PCin, PCp4, INT, entryPoint, imm, jTarget, zero, branch, jump);
	output [31:0] PCin;
	input [31:0] PCp4, entryPoint, imm;
	input [25:0] jTarget;
	input INT, zero, branch, jump;
	wire [31:0] immX4, bTarget, jTargetX4, choiceA, choiceB;
	wire doBranch, zf;
	assign immX4[31:2] = imm[29:0];
	assign immX4[1:0] = 2'b00; 						//immX4 is the real address (imm * 4)
	yAlu beq(bTarget, zf, PCp4, immX4, 3'b010);				//bTarget = PCp4 + imm * 4
	and (doBranch, branch, zero); 						//doBranch
	yMux #(32) mux1(choiceA, PCp4, bTarget, doBranch);			//if jump branch or execute the next
	assign jTargetX4[31:28] = PCp4[31:28];
	assign jTargetX4[27:2] = jTarget[25:0];
	assign jTargetX4[1:0] = 2'b00;
	yMux #(32) mux2(choiceB, choiceA, jTargetX4, jump);			// if not jump then use choiceA
	yMux #(32) mux3(PCin, choiceB, entryPoint, INT);			// choose between previous and entryPoint
endmodule
//-----------------------------------------------------------------------------------------------
//-----------------------------------yC1---------------------------------------------------------

module yC1(rtype, lw, sw, jump, branch, opCode);
	output rtype, lw, sw, jump, branch;
	input [5:0] opCode;
	wire [0:0] not5 ,not4, not3, not2, not1, not0;
	not (not5, opCode[5]);
	not (not4, opCode[4]);
	not (not3, opCode[3]);
	not (not2, opCode[2]);
	not (not1, opCode[1]);
	not (not0, opCode[0]);
	and (rtype, not5, not4, not3, not2, not1, not0);			//--------R-Type(000000)---------
	and (jump, not5, not4, not3, not2, opCode[1], not0);			//--------Jump(000010)-----------
	and (branch, not5, not4,not3, opCode[2], not1, not0);			//--------branch(000100)---------
	and (sw, opCode[5], not4 ,opCode[3], not2, opCode[1], opCode[0]);	//--------sw(101011)-------------
	and (lw, opCode[5], not4, not3, not2, opCode[1], opCode[0]);		//--------lw(100011)-------------
endmodule
//-----------------------------------------------------------------------------------------------
//-----------------------------------yC2---------------------------------------------------------

module yC2(RegDst, ALUSrc, RegWrite, Mem2Reg, MemRead, MemWrite, rtype, lw, sw, branch);
	output RegDst, ALUSrc, RegWrite, Mem2Reg, MemRead, MemWrite;
	input rtype, lw, sw, branch;
	assign RegDst = rtype;							//use [rd] field
	nor (ALUSrc, rtype, branch);						//0 - do calculation; 1 - add immediate
	nor (RegWrite, sw, branch);						//need to write to a register
	assign Mem2Reg = lw;
	assign MemRead = lw;
	assign MemWrite = sw;
endmodule
//-----------------------------------------------------------------------------------------------
//-----------------------------------yC3---------------------------------------------------------

module yC3(ALUop, rtype, branch);
	output [1:0] ALUop;
	input rtype, branch;
	assign ALUop[0] = branch;
	assign ALUop[1] = rtype;
endmodule
//-----------------------------------------------------------------------------------------------
//-----------------------------------yC4---------------------------------------------------------

module yC4(op, ALUop, fnCode);
	output [2:0] op;
	input [5:0] fnCode;
	input [1:0] ALUop;
	wire y1, y2;
	or (y1, fnCode[0], fnCode[3]);
	and (y2, fnCode[1], ALUop[1]);
	and (op[0], ALUop[1], y1);
	nand (op[1], ALUop[1], fnCode[2]);
	or (op[2], y2, ALUop[0]);
endmodule
//-----------------------------------------------------------------------------------------------
//-----------------------------------yChip-------------------------------------------------------

module yChip(ins, rd2, wb, entryPoint, INT, clk);
	output [31:0] ins, rd2, wb;
	input [31:0] entryPoint;
	input INT, clk;
	wire [31:0] wd, rd1, rd2, imm, ins, PCp4, z, memOut, wb, PCin;
	wire [25:0] jTarget;
	wire [5:0] opCode, fnCode;
	wire [2:0] op;
	wire [1:0] ALUop;
	wire zero, RegDst, RegWrite, ALUSrc, MemRead, MemWrite, Mem2Reg, jump, branch, rtype, lw, sw;
	yIF myIF(ins, PCp4, PCin, clk);
	yID myID(rd1, rd2, imm, jTarget, ins, wd, RegDst, RegWrite, clk);
	yEX myEX(z, zero, rd1, rd2, imm, op, ALUSrc);
	yDM myDM(memOut, z, rd2, clk, MemRead, MemWrite);
	yWB myWB(wb, z, memOut, Mem2Reg);
	assign wd = wb;
	yPC myPC(PCin, PCp4, INT, entryPoint, imm, jTarget, zero, branch, jump);
	assign opCode = ins[31:26];
	yC1 myC1(rtype, lw, sw, jump, branch, opCode);
	yC2 myC2(RegDst, ALUSrc, RegWrite, Mem2Reg, MemRead, MemWrite, rtype, lw, sw, branch);
	assign fnCode = ins[5:0];
	yC3 myC3(ALUop, rtype, branch);
	yC4 myC4(op, ALUop, fnCode);
endmodule

//-----------------------------------------------------------------------------------------------
//-----------------------------------END---------------------------------------------------------
