module pipelineRegister (clk, wrtEn, regEn, regEnOut, muxSel, muxSelOut, memEn, memEnOut, aluEn, aluEnOut, 
							PC, PCOut, instr, instrOut, reset);
	parameter DATA_BIT_WIDTH = 32;
	parameter N_REGS = (1 << INDEX_BIT_WIDTH);
	
	input clk, wrtEn, regEn, muxSel, memEn, aluEn, PC, instr, reset;
	output regEnOut, muxSelOut, memEnOut, aluEnOut, PCOut, instrOut;
	
	always @(posedge clk)
		if (wrtEn == 1'b1)
			Register regen(clk, reset, wrtEn, regEn, regEnOut);
			Register mux(clk, reset, wrtEn, muxSel, muxSelOut);
			Register mem(clk, reset, wrtEn, memEn, memEnOut);
			Register alu(clk, reset, wrtEn, aluEn, aluEnOut);
			Register pc(clk, reset, wrtEn, PC, PCOut);
			Register instruction(clk, reset, wrtEn, instr, instrOut);
	
endmodule