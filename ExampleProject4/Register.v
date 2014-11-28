module Register(clk, reset, wrtEn, dataIn, dataOut);
	parameter BIT_WIDTH = 32;
	parameter RESET_VALUE = 0;
	
	input clk, reset, wrtEn;
	input[BIT_WIDTH - 1: 0] dataIn;
	output[BIT_WIDTH - 1: 0] dataOut;
	reg[BIT_WIDTH - 1: 0] dataOut;
	
	always @(posedge clk) begin
		if (reset == 1'b1)
			dataOut <= RESET_VALUE;
		else if (wrtEn == 1'b1)
			dataOut <= dataIn;
	end
	
endmodule