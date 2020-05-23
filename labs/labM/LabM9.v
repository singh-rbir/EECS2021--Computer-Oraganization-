module labM;
   reg [31:0] PCin;
   reg        RegDst, RegWrite, clk, ALUSrc, MemRead, MemWrite, Mem2Reg;
   reg [2:0]  op;
   wire [31:0] wd, rd1, rd2, imm, ins, PCp4, z, memOut, wb;
   wire [25:0] jTarget;
   wire        zero;

   yIF myIF(ins, PCp4, PCin, clk);
   yID myID(rd1, rd2, imm, jTarget, ins, wd, RegDst, RegWrite, clk);
   yEX myEx(z, zero, rd1, rd2, imm, op, ALUSrc);
   yDM myDM(memOut, z, rd2, clk, MemRead, MemWrite);
   yWB myWB(wb, z, memOut, Mem2Reg);
   assign wd = wb;

   initial
     begin
        //------------------------------------Entry point
        PCin = 128;

        //------------------------------------Run program
        repeat (11)
          begin
             //---------------------------------Fetch an ins
             clk = 1; #1;

             //---------------------------------Set control signals
             RegDst = 0; RegWrite = 0; ALUSrc = 1; op = 3'b010;

             // R format
             if (ins[31:26] == 0)
               begin
                  RegDst = 1;
                  RegWrite = 1;
                  ALUSrc = 0;
                  MemRead = 0;
                  MemWrite = 0;
                  Mem2Reg = 0;

                  // add
                  if (ins[5:0] == 'h20)
                    op = 3'b010;
                  // or
                  else if (ins[5:0] == 'h25)
                    op = 3'b001;
               end

             // J format (jump)
             else if (ins[31:26] == 'h2)
               begin
                  RegDst = 0;
                  RegWrite = 0;
                  ALUSrc = 1;
                  MemRead = 0;
                  MemWrite = 0;
                  Mem2Reg = 0;
               end

             // lw
             else if (ins[31:26] == 'h23)
               begin
                  RegDst = 0;
                  RegWrite = 1;
                  ALUSrc = 1;
                  MemRead = 1;
                  MemWrite = 0;
                  Mem2Reg = 1;
               end

             // beq
             else if (ins[31:26] == 'h4)
               begin
                  RegDst = 0;
                  RegWrite = 0;
                  ALUSrc = 0;
                  MemRead = 0;
                  MemWrite = 0;
                  Mem2Reg = 0;
               end

             // addi
             else if (ins[31:26] == 'h8)
               begin
                  RegDst = 0;
                  RegWrite = 1;
                  ALUSrc = 1;
                  MemRead = 0;
                  MemWrite = 0;
                  Mem2Reg = 0;
               end

             // sw
             else if (ins[31:26] == 'h2b)
               begin
                  RegDst = 0;
                  RegWrite = 0;
                  ALUSrc = 1;
                  MemRead = 0;
                  MemWrite = 1;
                  Mem2Reg = 0;
               end

             //---------------------------------Execute the ins
             clk = 0; #1;

             //---------------------------------View results
             $display("%h: rd1=%2d rd2=%2d z=%3d zero=%b wb=%2d",
                      ins, rd1, rd2, z, zero, wb);

             //---------------------------------Prepare for the next ins
             PCin = PCp4;
          end
        $finish;
     end
endmodule
