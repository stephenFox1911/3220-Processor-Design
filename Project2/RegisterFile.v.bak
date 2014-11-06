module RegisterFile (clk, wrtEn, wrtIndex, rdIndex1, rdIndex2, dataIn, dataOut1, dataOut2);
	parameter INDEX_BIT_WIDTH = 4;
	parameter DATA_BIT_WIDTH = 32;
	parameter N_REGS = (1 << INDEX_BIT_WIDTH);
	
	input clk;
	input wrtEn;
	input [3: 0] wrtIndex, rdIndex1, rdIndex2;
	input [31: 0] dataIn;
	output [31: 0] dataOut1, dataOut2;
	
	reg[DATA_BIT_WIDTH - 1: 0] data [0: N_REGS];
	
	always @(posedge clk)
		if (wrtEn == 1'b1)
			data[wrtIndex] <= dataIn;
			
	assign dataOut1 = data[rdIndex1];
	assign dataOut2 = data[rdIndex2];
	
endmodule