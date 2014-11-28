module Mux2to1(sel, dInSrc1, dInSrc2, dOut);
	parameter BIT_WIDTH = 32;
  
	input sel;
	input [(BIT_WIDTH - 1) : 0] dInSrc1, dInSrc2;
	output [(BIT_WIDTH - 1) : 0] dOut;
  
	assign dOut = sel ? dInSrc2 : dInSrc1;
endmodule
