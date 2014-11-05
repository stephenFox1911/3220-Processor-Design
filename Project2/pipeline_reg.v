module pipeline_reg(clk, reset, buffWrEn, regWrEn, memWren, mulSel, aluOut, PC, instrType, branchEn, memWrenOut, mulSelOut, aluOutOut, PCOut, instrTypeOut, branchEnOut);
	parameter BIT_WIDTH = 32;

	input clk, reset;
	input regWrEn, memWren, branchEn;
	input [1:0] mulSel;
	input [BIT_WIDTH - 1] aluOut, PC;
	input [3:0] instrType; //not sure about this
	
	output reg regWrEnOut, memWrenOut, branchEnOut;
	output reg [1:0] mulSelOut;
	output reg [BIT_WIDTH - 1] aluOutOut, PCOut;
	output reg [3:0] instrTypeOut; //not sure about this
	//I think we also need something for the register file write addr
	
	bufRegister #(.BIT_WIDTH(1)) regWrEnBuff (.clk(clk), .reset(reset), .wrtEn(buffWrEn), .dataIn(regWrEn), .dataOut(regWrEnOut));
	bufRegister #(.BIT_WIDTH(1)) memWrEnBuff (.clk(clk), .reset(reset), .wrtEn(buffWrEn), .dataIn(memWrEn), .dataOut(memWrEnOut));
	bufRegister #(.BIT_WIDTH(1)) branchEnBuff (.clk(clk), .reset(reset), .wrtEn(buffWrEn), .dataIn(branchEn), .dataOut(branchEnOut));
	
	bufRegister #(.BIT_WIDTH(2)) mulSelBuff (.clk(clk), .reset(reset), .wrtEn(buffWrEn), .dataIn(mulSel), .dataOut(mulSelOut));
	
	bufRegister #(.BIT_WIDTH(4)) instrTypeBuff (.clk(clk), .reset(reset), .wrtEn(buffWrEn), .dataIn(instrType), .dataOut(instrTypeOut));
	
	bufRegister #(.BIT_WIDTH(BIT_WIDTH)) aluOutBuff (.clk(clk), .reset(reset), .wrtEn(buffWrEn), .dataIn(aluOut), .dataOut(aluOutOut));
	bufRegister #(.BIT_WIDTH(BIT_WIDTH)) PCBuff (.clk(clk), .reset(reset), .wrtEn(buffWrEn), .dataIn(PC), .dataOut(PCOut));


endmodule
