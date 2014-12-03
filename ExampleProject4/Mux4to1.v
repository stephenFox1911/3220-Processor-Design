module Mux4to1(sel, dInSrc1, dInSrc2, dInSrc3, dInSrc4, dOut);
	parameter BIT_WIDTH = 32;
	
	input [1 : 0] sel;
	input [BIT_WIDTH - 1 : 0] dInSrc1, dInSrc2, dInSrc3, dInSrc4;
	output [BIT_WIDTH - 1 : 0] dOut;
  
	assign dOut = (sel == 0) ? dInSrc1:
						(sel == 1) ? dInSrc2:
						(sel == 2) ? dInSrc3:
						dInSrc4;
					  
endmodule
