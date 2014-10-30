module Mux4to1 (sel, dIn0, dIn1, dIn2, dIn3, dOut);
	parameter DATA_BIT_WIDTH = 32;
	
	input [1:0] sel;
	input [DATA_BIT_WIDTH - 1: 0] dIn0;
	input [DATA_BIT_WIDTH - 1: 0] dIn1;
	input [DATA_BIT_WIDTH - 1: 0] dIn2;
	input [DATA_BIT_WIDTH - 1: 0] dIn3;
	
	output reg [DATA_BIT_WIDTH - 1: 0] dOut;
	
	always @ (*) begin
		case(sel)
			2'd0: dOut <= dIn0;
			2'd1: dOut <= dIn1;
			2'd2: dOut <= dIn2;
			2'd3: dOut <= dIn3;
		endcase
	end
	
endmodule