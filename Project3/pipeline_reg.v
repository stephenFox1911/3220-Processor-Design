module pipeline_reg(clk, reset, buffWrEn, regWrEn, regWrAddr, dataIn, memWrEn, mulSel, aluOut, PC, isLoad, isStore, regWrEnOut, regWrAddrOut, dataInOut, memWrEnOut, mulSelOut, aluOutOut, PCOut, isLoadOut, isStoreOut);
	parameter BIT_WIDTH = 32;

	input clk, reset;
	input buffWrEn;
	input regWrEn, memWrEn, isLoad, isStore;
	input [1:0] mulSel;
	input [3:0] regWrAddr;
	input [BIT_WIDTH - 1:0] aluOut, PC, dataIn;
	
	output regWrEnOut, memWrEnOut, isLoadOut, isStoreOut;
	output [1:0] mulSelOut;
	output [3:0] regWrAddrOut;
	output [BIT_WIDTH - 1:0] aluOutOut, PCOut, dataInOut;
	//I think we also need something for the register file write addr
	
	bufRegister #(.BIT_WIDTH(1)) regWrEnBuff (.clk(clk), .reset(reset), .wrtEn(buffWrEn), .dataIn(regWrEn), .dataOut(regWrEnOut));
	bufRegister #(.BIT_WIDTH(1)) memWrEnBuff (.clk(clk), .reset(reset), .wrtEn(buffWrEn), .dataIn(memWrEn), .dataOut(memWrEnOut));
	bufRegister #(.BIT_WIDTH(1)) isStoreBuff (.clk(clk), .reset(reset), .wrtEn(buffWrEn), .dataIn(isStore), .dataOut(isStoreOut));
	bufRegister #(.BIT_WIDTH(1)) isLoadBuff (.clk(clk), .reset(reset), .wrtEn(buffWrEn), .dataIn(isLoad), .dataOut(isLoadOut));
	
	bufRegister #(.BIT_WIDTH(2)) mulSelBuff (.clk(clk), .reset(reset), .wrtEn(buffWrEn), .dataIn(mulSel), .dataOut(mulSelOut));
	
	bufRegister #(.BIT_WIDTH(4)) regWrAddrBuff (.clk(clk), .reset(reset), .wrtEn(buffWrEn), .dataIn(regWrAddr), .dataOut(regWrAddrOut));
	
	bufRegister #(.BIT_WIDTH(BIT_WIDTH)) aluOutBuff (.clk(clk), .reset(reset), .wrtEn(buffWrEn), .dataIn(aluOut), .dataOut(aluOutOut));
	bufRegister #(.BIT_WIDTH(BIT_WIDTH)) PCBuff (.clk(clk), .reset(reset), .wrtEn(buffWrEn), .dataIn(PC), .dataOut(PCOut));
	bufRegister #(.BIT_WIDTH(BIT_WIDTH)) dataInBuff (.clk(clk), .reset(reset), .wrtEn(buffWrEn), .dataIn(dataIn), .dataOut(dataInOut));


endmodule
