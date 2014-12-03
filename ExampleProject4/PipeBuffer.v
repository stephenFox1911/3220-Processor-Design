module PipeBuffer (
		clk, rst, IRQ, nextDrIn, nextDrOut, dFromAlu, 
		dPipeAluOut, sr2FromAlu, dSr2Out, branchIn, 
		branchOut, IHA, IRA, pipePcIn, pipePcOut, ctrlIn, 
		memtoReg, memWrite, regWrite, pcMux, jal, flush,
		sysWrenIn, sysWrenOut, sysReadIn, sysReadOut, 
		sysSelIn, sysSelOut, sysRetIn, sysRetOut
	);

	parameter REG_WIDTH = 4;
	parameter BIT_WIDTH = 32;
	parameter CTRL_BIT_WIDTH = 5;
	parameter RESET_VALUE = 0;

	input clk, rst, IRQ, sysWrenIn, sysReadIn, sysRetIn;
	input [REG_WIDTH - 1 : 0] nextDrIn, sysSelIn;
	input [BIT_WIDTH - 1 : 0] dFromAlu, sr2FromAlu, branchIn, pipePcIn, IHA, IRA;
	input [CTRL_BIT_WIDTH - 1 : 0] ctrlIn;
	output reg [REG_WIDTH - 1 : 0] nextDrOut, sysSelOut;
	output reg [BIT_WIDTH - 1 : 0] dPipeAluOut, dSr2Out, branchOut, pipePcOut;
	output reg pcMux, jal, memtoReg, memWrite, regWrite, sysWrenOut, sysReadOut, sysRetOut;
	output reg flush;

	always @ (posedge clk) begin
		if (rst == 1'b1) {nextDrOut, dPipeAluOut, dSr2Out, pcMux, branchOut, jal, pipePcOut, memtoReg, memWrite, regWrite, flush} <= RESET_VALUE;
		else if (IRQ && !flush) {branchOut, pcMux, jal, flush} <= {IHA, 3'b101};
		else if ((ctrlIn[2] & dFromAlu) && !flush) {branchOut, pcMux, jal, flush} <= {branchIn, 3'b101}; //JAL
		else if (ctrlIn[1] && !flush) {branchOut, pcMux, jal, flush} <= {dFromAlu, 3'b111};
		else if (sysReadIn) {branchOut, pcMux, jal, flush} <= {32'b0, 3'b010};
		else if (sysRetIn) {branchOut, pcMux, jal, flush} <= {IRA, 3'b101};
		else {branchOut, pcMux, jal, flush} <= 0;
		if (flush) {branchOut, pcMux, jal, flush} <= 0;
		{nextDrOut, dPipeAluOut, dSr2Out, pipePcOut, sysWrenOut, sysReadOut, sysSelOut, sysRetOut, memtoReg, memWrite, regWrite} 
			<= {nextDrIn, dFromAlu, sr2FromAlu, pipePcIn, sysWrenIn, sysReadIn, sysSelIn, sysRetIn, ctrlIn[4], flush ? 2'b0 : {ctrlIn[3], ctrlIn[0]}};
	end

endmodule
