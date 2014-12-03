module SCProcController(opcode, aluControl, alusrc, branchSel, memWriteSel, ctrlBit, sysWrEn, sysRead, sysRet);
	input [7:0] opcode;
	output [7:0] aluControl;
	output [4:0] ctrlBit;
	output alusrc, branchSel, memWriteSel, sysWrEn, sysRead, sysRet;
	
	reg [15:0] ctrl;

	assign aluControl[7:0] = ctrl[15:8];
	assign ctrlBit[4:0] = {ctrl[5:2], ctrl[0]};
	/*
	bit 4: selects datamuxOut (wrREg data)
	bit 3: memWrite enable bit
	bit 2: this & aluOut means JAL, use for RETI?
	bit 1: jump to aluOut, this plus bit 4 writes incPC to regfile, else DBUS
	bit 0: regfile write enable bit
	*/
	assign alusrc = ctrl[1];
	assign branchSel = ctrl[6];		
	assign memWriteSel = ctrl[7];		//used to sel reg2 in rsr and wsr
	assign sysWrEn = (ctrl[7] & (ctrl[6:0] == 0)) ? 1 : 0;
	assign sysRead = (ctrl[7] & ctrl[5] & ctrl[0]) ? 1: 0;
	assign sysRet = (ctrl[7:0] == 0) ? 1 : 0;

	always @(*) begin
		if(opcode[7:4] == 4'b1111) begin // SYS
			if(opcode[3:0] == 4'b0010) ctrl <= {opcode, 8'b10100001};		//RSR
			else if (opcode[3:0] == 4'b0011) ctrl <= {opcode, 8'b10000000};	//WSR
			else ctrl <= {opcode, 8'b00000000}; 		//RETI	
		end else if (opcode[4]) begin
			if (opcode[5]) ctrl <= {opcode, 8'b00000111};		// JAL
			else if (opcode[6]) ctrl <= {opcode, 8'b10010010};	// SW
			else ctrl <= {opcode, 8'b00100011};					// LW
		end else if (opcode[7]) ctrl <= {opcode, 8'b00000011};	// ALUI, CMPI 
		else if (opcode[6])	ctrl <= {opcode, 8'b01001000};		// BCOND
		else ctrl <= {opcode, 8'b00000001};						// ALUR, CMPR 
	end

endmodule
