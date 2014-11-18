module Mux2to1 (sel, dIn1, dIn2, dOut);
	parameter DATA_BIT_WIDTH = 4;
	
	input sel;
	input [DATA_BIT_WIDTH - 1: 0] dIn1;
	input [DATA_BIT_WIDTH - 1: 0] dIn2;
	output reg [DATA_BIT_WIDTH - 1: 0] dOut;
	
	always @ (*) begin
		if (sel)
			dOut <= dIn2;
		else
			dOut <= dIn1;
	end
	
endmodule