module LabM;

reg clk, read, write;
reg [31:0] address, memIn;
wire [31:0] memOut;

mem data(memOut, address, memIn, clk, read, write);

initial
begin
  address = 16'h28; write = 0; read = 1;
  repeat (11)
  begin
  #1;
    // R format:
    // opcode(6) rs(5) rt(5) rd(5) shamt(5) funct(6)
    // note: in order to match the given output in the lab manual
    // the shamt (memOut[10:6]) is not displayed in the output.
    if (memOut[31:26] == 0)
     $display("%0d %0d %0d %0d %0d", memOut[31:26], memOut[25:21],
              memOut[20:16], memOut[15:11], memOut[5:0]);
    // J format
    // opcode(6) address(26)
    else if (memOut[31:26] == 2)
     $display("%0d %0d", memOut[31:26], memOut[25:0]);
    // I format
    // opcode(6) rs(5) rt(5) immediate(16)
    else
     $display("%0d %0d %0d %0d", memOut[31:26], memOut[25:21],
              memOut[20:16], memOut[15:0]);

    address = address + 4;
  end
$finish;
end

endmodule
