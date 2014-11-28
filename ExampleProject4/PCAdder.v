module PCAdder(dIn1, dIn2, dOut);
	input signed [31:0] dIn1, dIn2;
	output [31:0] dOut;
	assign dOut = dIn1 + (dIn2 << 2);
endmodule