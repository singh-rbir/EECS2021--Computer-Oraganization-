module yIF(ins, PC, PCp4, PCin, clk);
output [31:0] ins, PC, PCp4;
input [31:0] PCin;
input clk;
wire zero;
wire read, write, enable;
wire [31:0] a, memIn;
wire [2:0] op;
register #(32) pcReg(PC, PCin, clk, enable);
mem insMem(ins, PC, memIn, clk, read, write);
ALU myAlu(PCp4, zero, a, PC, op);
assign enable = 1'b1;
assign a = 32'h0004;
assign op = 3'b010;
assign read = 1'b1;
assign write = 1'b0;
endmodule 

module yPC(PCin, PC, PCp4,INT,entryPoint,branchImm,jImm,zero,isbranch,isjump);
output [31:0] PCin;
input [31:0] PC, PCp4, entryPoint, branchImm;
input [31:0] jImm;
input INT, zero, isbranch, isjump;
wire [31:0] branchImmX4, jImmX4, jImmX4PPCp4, bTarget, choiceA, choiceB;
wire doBranch, zf;
// Shifting left branchImm twice
assign branchImmX4[31:2] = branchImm[29:0];
assign branchImmX4[1:0] = 2'b00;
// Shifting left jump twice
assign jImmX4[31:2] = jImm[29:0];
assign jImmX4[1:0] = 2'b00;
// adding PC to shifted twice, branchImm
ALU bALU(bTarget, zf, PC, branchImmX4, 3'b010);
// adding PC to shifted twice, jImm
ALU jALU(jImmX4PPCp4, zf, PC, jImmX4, 3'b010);
// deciding to do branch
and (doBranch, isbranch, zero);
yMux #(32) mux1(choiceA, PCp4, bTarget, doBranch);
yMux #(32) mux2(choiceB, choiceA, jImmX4PPCp4, isjump);
yMux #(32) mux3(PCin, choiceB, entryPoint, INT);
endmodule

module yC1(isStype, isRtype, isItype, isLw, isjump, isbranch, opCode);
output isStype, isRtype, isItype, isLw, isjump, isbranch;
input [6:0] opCode;
wire lwor, ISselect, JBselect, sbz, sz;
// opCode
// lw 0000011
// I-Type 0010011
// R-Type 0110011
// SB-Type 1100011
// UJ-Type 1101111
// S-Type 0100011
// Detect UJ-type
assign isjump=opCode[3];
// Detect lw
or (lwor, opCode[6], opCode[5], opCode[4], opCode[3], opCode[2]);
not (isLw, lwor);
// Select between S-Type and I-Type
xor (ISselect, opCode[6], opCode[5], opCode[4], opCode[3], opCode[2]);
and (isStype, ISselect, opCode[5]);
and (isItype, ISselect, opCode[4]);
// Detect R-Type
and (isRtype, opCode[5], opCode[4]);
// Select between JAL and Branch
and (JBselect, opCode[6], opCode[5]);
not (sbz, opCode[3]);
and (isbranch, JBselect, sbz);
endmodule

module yC2(RegWrite, ALUSrc, MemRead, MemWrite, Mem2Reg, isStype, isRtype, isItype, isLw, isjump, isbranch);
output RegWrite, ALUSrc, MemRead, MemWrite, Mem2Reg;
input isStype, isRtype, isItype, isLw, isjump, isbranch;
// You need two or gates and 3 assignments;
	assign Mem2Reg = isLw;
    assign MemRead = isLw;
    assign MemWrite = isStype;
	
	or(RegWrite, isRtype, isLw, isItype);
	or(ALUSrc, isjump, isLw, isItype, isStype);

endmodule

module yC3(ALUop, isRtype, isbranch);
output [1:0] ALUop;
input isRtype, isbranch;

// build the circuit
// Hint: you can do it in only 2 lines
assign ALUop[1] = isRtype;
assign ALUop[0] = isbranch;

endmodule

module yC4(op, ALUop, funct3);
output [2:0] op;
input [2:0] funct3;
input [1:0] ALUop;
wire ALUAndXorF12, XorF12, NotALU1, NotF1, XorF01, ALUAndXorF01, ALU0OrALUF12, NotALU1OrF1, ALU1OrF01;

//operation 2
xor myF12(XorF12, funct3[1], funct3[2]);
and myALU1F12(ALUAndXorF12, ALUop[1], XorF12);
or myALU0orALUF12(ALU0OrALUF12, ALUAndXorF12, ALUop[0]);

//operation 1
not myNotALU1(NotALU1, ALUop[1]);
not myNotF1(NotF1, funct3[1]);
or myNotALU1OrF1(NotALU1OrF1, NotALU1, NotF1);

//operation 0
xor myXorF01(XorF01, funct3[0], funct3[1]);
and ALUAndXorF01(ALUAndXorF01, XorF01, ALUop[1]);

// instantiate and connect
assign op[2] = ALU0OrALUF12;
assign op[1] = NotALU1OrF1;
assign op[0] = ALUAndXorF01;

endmodule

//modified yChip, useful outputs are destination register(z) and PC
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


endmodule



module yID(rd1, rd2, immOut, jTarget, branch, ins, wd, RegWrite, clk);
output [31:0] rd1, rd2, immOut;
output [31:0] jTarget;
output [31:0] branch;
input [31:0] ins, wd;
input RegWrite, clk;
wire [19:0] zeros, ones; // For I-Type and SB-Type
wire [11:0] zerosj, onesj; // For UJ-Type
wire [31:0] imm, saveImm; // For S-Type
rf myRF(rd1, rd2, ins[19:15], ins[24:20], ins[11:7], wd, clk, RegWrite);
assign imm[11:0] = ins[31:20];
assign zeros = 20'h00000;
assign ones = 20'hFFFFF;
yMux #(20) se(imm[31:12], zeros, ones, ins[31]);
assign saveImm[11:5] = ins[31:25];
assign saveImm[4:0] = ins[11:7];
yMux #(20) saveImmSe(saveImm[31:12], zeros, ones, ins[31]);
yMux #(32) immSelection(immOut, imm, saveImm, ins[5]);
assign branch[11] = ins[31];
assign branch[10] = ins[7];
assign branch[9:4] = ins[30:25];
assign branch[3:0] = ins[11:8];
yMux #(20) bra(branch[31:12], zeros, ones, ins[31]);
assign zerosj = 12'h000;
assign onesj = 12'hFFF;
assign jTarget[19] = ins[31];
assign jTarget[18:11] = ins[19:12];
assign jTarget[10] = ins[20];
assign jTarget[9:0] = ins[30:21];
yMux #(12) jum(jTarget[31:20], zerosj, onesj, jTarget[19]);

endmodule

module yEX(z, zero, rd1, rd2, imm, op, ALUSrc);
output [31:0] z;
output zero;
input [31:0] rd1, rd2, imm;
input [2:0] op;
input ALUSrc;
wire [31:0] bInOut;

yMux #(32) mux(bInOut, rd2, imm, ALUSrc);
ALU alu(z, zero, rd1, bInOut, op);
endmodule


module yDM(memOut, exeOut, rd2, clk, MemRead, MemWrite);
output [31:0] memOut;
input [31:0] exeOut, rd2;
input clk, MemRead, MemWrite;
// instantiate the circuit (only one line)
mem myMem(memOut, exeOut, rd2, clk,MemRead, MemWrite);
endmodule
//---------------------------------------------------------------


module yWB(wb, exeOut, memOut, Mem2Reg);
output [31:0] wb;
input [31:0] exeOut, memOut;
input Mem2Reg;
// instantiate the circuit (only one line)
yMux #(32) mux1(wb, exeOut, memOut, Mem2Reg);
endmodule



module ALU(z,zero, a, b, op);
input[31:0] a, b;
input [2:0] op;
output [31:0] z, arithOut, arithSLT;
output zero;
wire[31:0] andAB, orAB, slt;
wire cout, condition;

wire [15:0]   z16;
wire [7:0]    z8;
wire [3:0]    z4;
wire [1:0]    z2;
wire z1, z0;

assign slt[31:1] = 0; 


or or16[15:0] (z16, z[15: 0], z[31:16]);
or or8[7:0] (z8, z16[7: 0], z16[15:8]);
or or4[3:0] (z4, z8[3: 0], z8[7:4]);
or or2[1:0] (z2, z4[1:0], z4[3:2]);
or or1[15:0] (z1, z2[1], z2[0]);
not m_not (z0, z1);
assign zero = z0;



xor my_xor (condition, a[31], b[31]);
and my_and[31:0] (andAB, a, b);
or my_or[31:0] (orAB, a, b);
yMux #(1) muxSLT(slt[0], arithSLT[31], a[31], condition);
yArith #(32) arith2(arithSLT, cout, a, b, op[2]);
yArith #(32) arith(arithOut, cout, a, b, op[2]);
yMux4to1 #(32) mux(z, andAB, orAB, arithOut, slt, op[1:0]);
 
endmodule

module yArith(z, cout, a, b, ctrl);
parameter SIZE = 2;
output [SIZE-1:0] z;
output cout;

input [SIZE-1:0] a, b;
input ctrl;

wire[SIZE-1:0] notB, tmp;
wire cin;

assign cin = ctrl;
not my_not [SIZE-1:0] (notB, b);
yMux #(SIZE) mux(tmp, b, notB, cin);
yAdder adder(z, cout, a, tmp, cin);

endmodule

module yMux4to1(z, a0, a1, a2, a3, c);
parameter SIZE = 2;
output [SIZE-1:0] z;
input [SIZE-1:0] a0, a1, a2, a3;
input [1:0] c;
wire [SIZE-1:0] zLo, zHi;

yMux #(SIZE) lo(zLo, a0, a1, c[0]);
yMux #(SIZE) hi(zHi, a2, a3, c[0]);
yMux #(SIZE) final(z, zLo, zHi, c[1]);


endmodule  

module yMux1(z, a, b, c);

output z;
input a, b, c;
wire notC, upper, lower;
not my_not(notC, c);
and upperAnd(upper, a, notC);
and lowerAnd(lower, c, b);
or my_or(z, upper, lower);


endmodule 

module yMux(z, a, b, c);
parameter SIZE = 2;
output [SIZE-1:0] z;
input [SIZE-1:0] a, b;
input c;
yMux1 mine[SIZE-1:0](z, a, b, c);
endmodule  

module yAdder1(z, cout, a, b, cin);
output z, cout;
input a, b, cin;
xor left_xor(tmp, a, b);
xor right_xor(z, cin, tmp);
and left_and(outL, a, b);
and right_and(outR, tmp, cin);
or my_or(cout, outR, outL);
endmodule

module yAdder(z, cout, a, b, cin);
output [31:0] z;
output cout;
input [31:0] a, b;
input cin;
wire[31:0] in, out;
yAdder1 mine[31:0](z, out, a, b, in);
assign in[0] = cin;
assign in[1] = out[0];
assign in[2] = out[1];
assign in[3] = out[2];
assign in[4] = out[3];
assign in[5] = out[4];
assign in[6] = out[5];
assign in[7] = out[6];
assign in[8] = out[7];
assign in[9] = out[8];
assign in[10] = out[9];
assign in[11] = out[10];
assign in[12] = out[11];
assign in[13] = out[12];
assign in[14] = out[13];
assign in[15] = out[14];
assign in[16] = out[15];
assign in[17] = out[16];
assign in[18] = out[17];
assign in[19] = out[18];
assign in[20] = out[19];
assign in[21] = out[20];
assign in[22] = out[21];
assign in[23] = out[22];
assign in[24] = out[23];
assign in[25] = out[24];
assign in[26] = out[25];
assign in[27] = out[26];
assign in[28] = out[27];
assign in[29] = out[28];
assign in[30] = out[29];
assign in[31] = out[30];
assign cout = out[31];
endmodule



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


module mem(memOut, address, memIn, clk, read, write);
/****************************
Behavioral Memory Unit.
Written by H. Roumani, 2009.
****************************/

parameter DEBUG = 0;

parameter CAPACITY = 16'hffff;
input clk, read, write;
input [31:0] address, memIn;
output [31:0] memOut;
reg [31:0] memOut;
reg [31:0] arr [0:CAPACITY];
reg fresh = 1;

always @(read or address or arr[address])
begin
	if (fresh == 1)
	begin
		fresh = 0;
		$readmemh("ram.dat", arr);
	end

	if (read == 1)
	begin
		if (address[1:0] != 2'b00)
		begin
			//$display("Unaligned Load Address %d", address); 
			memOut = 32'hxxxxxxxx;
		end
		else if (address > CAPACITY)
		begin
			//$display("Address %h out of range %d", address, CAPACITY);
			memOut = 32'hxxxxxxxx;
		end
		else
		begin
			memOut = arr[address];
		end
	end
end

always @(posedge clk)
begin
	if (write == 1)
	begin
		if (address[1:0] != 2'b00)
		begin
			//$display("Unaligned Store Address %d", address);
		end
		else if (address > CAPACITY)
		begin
			$display("Address %d out of range %d", address, CAPACITY);
		end
		else
		begin
			arr[address] <= memIn;
			if (DEBUG != 0) $display("MEM: wrote %0dd at address %0dd", memIn, address);
		end
	end
end

endmodule

module register(q, d, clk, enable);

/****************************
An Edge-Triggerred Register.
Written by H. Roumani, 2008.
****************************/


parameter SIZE = 2;

output [SIZE-1:0] q;

input [SIZE-1:0] d;

input clk, enable;


ff myFF[SIZE-1:0](q, d, clk, enable);



endmodule

module rf(RD1,RD2, RN1,RN2, WN,WD, clk, W);
/****************************
Behavioral register file
Written by H. Roumani, 2009
****************************/
parameter DEBUG = 0;

input clk, W;
input [4:0] RN1, RN2, WN;
input [31:0] WD;
output [31:0] RD1, RD2;

reg [31:0] RD1, RD2;
reg [31:0] arr [1:31];

always @(RN1 or arr[RN1])
	if (RN1 == 0)
		RD1 = 0;
	else
	begin
		RD1 = arr[RN1];
		if (DEBUG != 0) $display("RF: read %0dd from reg#%0d", RD1, RN1);
	end

always @(RN2 or arr[RN2])
	if (RN2 == 0)
		RD2 = 0;
	else
	begin
		RD2 = arr[RN2];
		if (DEBUG != 0) $display("RF: read %0dd from reg#%0d", RD2, RN2);
	end
		

always @(posedge clk) 
	if (W == 1 && WN != 0)
	begin
		arr[WN] = WD;
		if (DEBUG != 0) $display("RF: wrote %0dd to reg#%0d", WD, WN);
	end

endmodule



