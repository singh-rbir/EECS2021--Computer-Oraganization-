module labN;
	reg [31:0] entryPoint, PC;
	reg clk, INT;
	wire [31:0] ins, rd2, wb;
	yChip myChip(ins, rd2, PC, wb, entryPoint, INT, clk);
	initial
		begin
			entryPoint = 128; INT = 1; clk = 0; #1;
		repeat (43)
		begin
				clk = ~clk; #1; INT = 0;
				clk = ~clk; #1;
				$display("current PC: %h rd2 identity= content=%2d", ins, rd2);
		end
	$finish;
	end
endmodule
