module PcLogic(dataIn, dataOut);
	parameter PC_BIT_WIDTH = 32;
	input  [PC_BIT_WIDTH - 1: 0] dataIn;
	output reg [PC_BIT_WIDTH - 1: 0] dataOut;
  
	always @(dataIn) begin
		dataOut <= dataIn + 4;
	end
endmodule