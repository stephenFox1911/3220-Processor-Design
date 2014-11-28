module RegisterFile(CLK,WE,LOCK,DIN,DR,SR1,SR2,SR1OUT,SR2OUT);
	parameter BIT_WIDTH = 32;
	parameter REG_WIDTH = 4;
	parameter REG_SIZE  = (1 << REG_WIDTH); 

	input CLK, WE, LOCK;
	input [BIT_WIDTH - 1 : 0] DIN;
	input [REG_WIDTH - 1 : 0] DR, SR1, SR2;
	output [BIT_WIDTH - 1 : 0] SR1OUT, SR2OUT;
	
	reg [BIT_WIDTH - 1 : 0] REGS [0 : REG_SIZE - 1];

	always @(posedge CLK)
		if (LOCK)
			if (WE)
				REGS[DR] <= DIN;	

	assign SR1OUT = (DR == SR1 && WE) ? DIN : REGS[SR1];
	assign SR2OUT = (DR == SR2 && WE) ? DIN : REGS[SR2];
	
endmodule


