module PCIncrement(dIn, dOut);
	input [31:0] dIn;
	output [31:0] dOut;
	assign dOut = dIn + 32'd4;
endmodule