module SCProcController(opcode, aluControl, alusrc, branchSel, memWriteSel, ctrlBit);
	input [7:0] opcode;
	output [7:0] aluControl;
	output [4:0] ctrlBit;
	output alusrc, branchSel, memWriteSel;
	
	reg [15:0] ctrl;

	assign aluControl[7:0] = ctrl[15:8];
	assign ctrlBit[4:0] = {ctrl[5:2], ctrl[0]};
	assign alusrc = ctrl[1];
	assign branchSel = ctrl[6];
	assign memWriteSel = ctrl[7];

	always @(*) begin
		if (opcode[4]) begin
			if (opcode[5]) ctrl <= {opcode, 8'b00000111};		// JAL
			else if (opcode[6]) ctrl <= {opcode, 8'b10010010};	// SW
			else ctrl <= {opcode, 8'b00100011};					// LW
		end else if (opcode[7]) ctrl <= {opcode, 8'b00000011};	// ALUI, CMPI 
		else if (opcode[6])	ctrl <= {opcode, 8'b01001000};		// BCOND
		else ctrl <= {opcode, 8'b00000001};						// ALUR, CMPR 
	end

endmodule
