module DataMemory(clk, addr, dataWrtEn, dataIn, dataOut);
	parameter ADDR_BIT_WIDTH = 11;
	parameter DATA_BIT_WIDTH = 32;
	parameter N_WORDS = (1 << ADDR_BIT_WIDTH);
	
	input clk;
	input[ADDR_BIT_WIDTH - 1: 0] addr;
	input dataWrtEn;
	input[DATA_BIT_WIDTH - 1: 0] dataIn;
	output[DATA_BIT_WIDTH - 1: 0] dataOut;

	
	reg[DATA_BIT_WIDTH - 1: 0] data[0: N_WORDS - 1];
	
	always @ (posedge clk) begin
		if (dataWrtEn) 
			data[addr] <= dataIn;
	end
	
	assign dataOut = data[addr];
	
endmodule
