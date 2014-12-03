module int_ctrl (clk,IRQ_k, IRQ_sw, IRQ_t, IRQ, IDN);
	parameter BIT_WIDTH = 32;

	
	input clk, IRQ_k, IRQ_sw, IRQ_t;
	output IRQ;
	output [BIT_WIDTH - 1 : 0] IDN;
	
	assign IRQ = IRQ_k || IRQ_sw || IRQ_t;
	
	assign IDN = IRQ_k ? 1:
						 IRQ_sw ? 2:
						 IRQ_t ? 3:
						 0;
	
endmodule