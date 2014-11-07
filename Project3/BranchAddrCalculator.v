module BranchAddrCalculator (nextPc, pcRel, branchAddr);
	parameter PC_BIT_WIDTH = 32;
	
	input  [PC_BIT_WIDTH - 1: 0] nextPc;
	input  [PC_BIT_WIDTH - 1: 0] pcRel;
	output [PC_BIT_WIDTH - 1: 0] branchAddr;
	
	wire signed [PC_BIT_WIDTH - 1: 0] pcRelSigned;
	
	assign pcRelSigned = pcRel;
	
	assign branchAddr = nextPc + (pcRelSigned << 2);
	
endmodule