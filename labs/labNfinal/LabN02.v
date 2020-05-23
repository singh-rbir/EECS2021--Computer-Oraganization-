module labN;
reg [31:0] entryPoint;
reg clk, INT;
wire [31:0] ins, wb, PC, z;

yChip myChip(ins, z, PC, wb, entryPoint, INT, clk);

initial
begin
	//------------------------------------Entry point
		entryPoint = 32'h28; INT = 1; #1;
	//------------------------------------Run program
	repeat (43)
	begin
	//---------------------------------Fetch an ins
		clk = 1; #1; INT = 0;
	//---------------------------------Execute the ins
		clk = 0; #1;
	//---------------------------------View results
	$display("PC:%h   rd:%h		ContentsOfRd:%h	 ", PC, ins[11:7], z);
	//---------------------------------Prepare for the next ins
	end

	$finish;
end

endmodule
