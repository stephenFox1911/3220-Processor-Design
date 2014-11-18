module ClkDivider(input clkIn, output clkOut);
	parameter divider = 25000000;
	parameter len = 31;
	reg[len: 0] counter = 0;
	reg clkReg = 0;
	
	assign clkOut = clkReg;
	
	always @(posedge clkIn) begin
		counter <= counter + 1;
		
		if (counter == divider) begin
			clkReg <= ~clkReg;
			counter <= 0;
		end
	end
endmodule


module Project2(SW,KEY,LEDR,LEDG,HEX0,HEX1,HEX2,HEX3,CLOCK_50);
	input  [9:0] SW;
	input  [3:0] KEY;
	input  CLOCK_50;
	output [9:0] LEDR;
	output [7:0] LEDG;
	output [6:0] HEX0,HEX1,HEX2,HEX3; 
	
	parameter DBITS         				 = 32;
	parameter INST_SIZE      				 = 32'd4;
	parameter INST_BIT_WIDTH				 = 32;
	parameter START_PC       			 	 = 32'h40;
	parameter REG_INDEX_BIT_WIDTH 		 = 4;
	parameter ADDR_KEY  						 = 32'hF0000010;
	parameter ADDR_SW   						 = 32'hF0000014;
	parameter ADDR_HEX  						 = 32'hF0000000;
	parameter ADDR_LEDR 						 = 32'hF0000004;
	parameter ADDR_LEDG 						 = 32'hF0000008;
  
	parameter IMEM_INIT_FILE				 = "Test2.mif";//"Sort2_counter.mif"; //"Sorter2.mif";
	parameter IMEM_ADDR_BIT_WIDTH 		 = 11;
	parameter IMEM_DATA_BIT_WIDTH 		 = INST_BIT_WIDTH;
	parameter IMEM_PC_BITS_HI     		 = IMEM_ADDR_BIT_WIDTH + 2;
	parameter IMEM_PC_BITS_LO     		 = 2;
	
	parameter DMEM_ADDR_BIT_WIDTH 		 = 11;
	parameter DMEM_DATA_BIT_WIDTH 		 = 32;
	parameter DMEM_ADDR_BITS_HI     		 = DMEM_ADDR_BIT_WIDTH + 2;
	parameter DMEM_ADDR_BITS_LO     		 = 2;
	
	parameter OP1_ALUR 					 = 4'b0000;
	parameter OP1_ALUI 					 = 4'b1000;
	parameter OP1_CMPR 					 = 4'b0010;
	parameter OP1_CMPI 					 = 4'b1010;
	parameter OP1_BCOND					 = 4'b0110;
	parameter OP1_SW   					 = 4'b0101;
	parameter OP1_LW   					 = 4'b1001;
	parameter OP1_JAL  					 = 4'b1011;
  
	// Add parameters for various secondary opcode values
  
	//PLL, clock genration, and reset generation
	wire clk, lock;
	//Pll pll(.inclk0(CLOCK_50), .c0(clk), .locked(lock));
	//PLL	PLL_inst (.inclk0 (CLOCK_50),.c0 (clk),.locked (lock));
	ClkDivider clkdi(CLOCK_50, clk);
	
	wire reset = SW[0]; //~lock;
	
	wire [DMEM_DATA_BIT_WIDTH - 1: 0] aluIn2;
	wire immSel;
	wire[DMEM_DATA_BIT_WIDTH - 1: 0] dataWord;
   wire [1:0] memOutSel;
	wire [3: 0] wrtIndex, rdIndex1, rdIndex2;
	wire [4: 0] sndOpcode;
	wire [15: 0] imm;
	wire regFileEn;
	wire dataWrtEn;
	wire [DMEM_DATA_BIT_WIDTH - 1: 0] dataIn, dataOut1, dataOut2;
	wire cmpOut_top;  
	wire [DMEM_DATA_BIT_WIDTH - 1: 0] aluOut;
	wire [DMEM_DATA_BIT_WIDTH - 1: 0] addrMemIn;
	wire [DMEM_DATA_BIT_WIDTH - 1: 0] dataMemIn;
	wire [DMEM_DATA_BIT_WIDTH - 1: 0] seImm;
	wire[IMEM_DATA_BIT_WIDTH - 1: 0] instWord;
	wire[DBITS - 1: 0] branchPc;
	wire isLoad, isStore;
	wire [31:0] dataMemoryOut;
	wire [1:0] dataMemOutSel;
	wire[DBITS - 1: 0] switchOut;
	wire[DBITS - 1: 0] keyOut;
	wire[DBITS - 1: 0] ledrOut;
	wire[DBITS - 1: 0] ledgOut;
	wire[DBITS - 1: 0] hexOut;
	wire swEn, ledrEn, ledgEn, keyEn, hexEn;
  
	// PC register
	wire pcWrtEn = 1'b1; // always right to PC
	wire[DBITS - 1: 0] pcIn; // Implement the logic that generates pcIn; you may change pcIn to reg if necessary
	wire[DBITS - 1: 0] pcOut;
	wire[DBITS - 1: 0] pcLogicOut;
	wire [1:0] pcSel; // 0: pcOut + 4, 1: branchPc
	
	Register #(.BIT_WIDTH(DBITS), .RESET_VALUE(START_PC)) pc (clk, reset, pcWrtEn, pcIn, pcOut);
	PcLogic pcLogic (pcOut, pcLogicOut);
	//Mux2to1 #(.DATA_BIT_WIDTH(DBITS)) muxPcOut (pcSel, pcLogicOut, branchPc, pcIn);
	Mux4to1 muxPcOut (pcSel, pcLogicOut, branchPc, aluOut, 32'd0, pcIn);

	
	// Instruction Memory
	InstMemory #(IMEM_INIT_FILE, IMEM_ADDR_BIT_WIDTH, IMEM_DATA_BIT_WIDTH) instMem (pcOut[IMEM_PC_BITS_HI - 1: IMEM_PC_BITS_LO], instWord);
  
	// Controller 
	Controller cont (.inst(instWord), .aluCmpIn(cmpOut_top), .sndOpcode(sndOpcode), .dRegAddr(wrtIndex), .s1RegAddr(rdIndex1), .s2RegAddr(rdIndex2), .imm(imm), 
							.regFileWrtEn(regFileEn), .immSel(immSel), .memOutSel(memOutSel), .pcSel(pcSel), .isLoad(isLoad), .isStore(isStore));
  
	// RegisterFile
	RegisterFile regFile (.clk(clk), .wrtEn(regFileEn), .wrtIndex(wrtIndex), .rdIndex1(rdIndex1), .rdIndex2(rdIndex2), .dataIn(dataIn), .dataOut1(dataOut1), .dataOut2(dataOut2));
 
	// ALU
	Alu alu1 (.ctrl(sndOpcode), .rawDataIn1(dataOut1), .rawDataIn2(aluIn2), .dataOut(aluOut), .cmpOut(cmpOut_top)); 
  
   // Sign Extension
	SignExtension #(.IN_BIT_WIDTH(16), .OUT_BIT_WIDTH(32)) se (imm, seImm);
 
	// ALU Mux
	Mux2to1 #(.DATA_BIT_WIDTH(DBITS)) muxAluIn (immSel, dataOut2, seImm, aluIn2);

	// Data Memory and I/O
	negRegister dataReg (clk, reset, 1'b1, aluOut, addrMemIn);
	DataMemory #(DMEM_ADDR_BIT_WIDTH, DMEM_DATA_BIT_WIDTH) dataMem (.clk(clk), .addr(addrMemIn[DMEM_ADDR_BITS_HI - 1: DMEM_ADDR_BITS_LO]), .dataWrtEn(dataWrtEn), .dataIn(dataOut2), .dataOut(dataWord));
	Mux4to1 muxMemOut (memOutSel, aluOut, dataMemoryOut, pcLogicOut, 32'd0, dataIn);
	Mux4to1 muxDataMemOut (dataMemOutSel, dataWord, switchOut, keyOut, 32'd0, dataMemoryOut);
	
	// Branch Address Calculator
	BranchAddrCalculator bac (.nextPc(pcLogicOut), .pcRel(seImm), .branchAddr(branchPc));
	
	// IO controller
	IO_controller ioCtrl (.dataAddr(aluOut), .isLoad(isLoad), .isStore(isStore), .dataWrtEn(dataWrtEn), .dataMemOutSel(dataMemOutSel), 
									.swEn(swEn), .keyEn(keyEn), .ledrEn(ledrEn), .ledgEn(ledgEn), .hexEn(hexEn));

	// KEYS, SWITCHES, HEXS, and LEDS are memeory mapped IO
	// SWITCH
	negRegister switchReg (clk, reset, swEn, {22'd0,SW}, switchOut);
	// LEDR
	negRegister ledrReg 	 (clk, reset, ledrEn, dataOut2, ledrOut); // 
	assign LEDR = ledrOut[9:0];
	// LEDG
	negRegister ledgReg 	 (clk, reset, ledgEn, dataOut2, ledgOut); // 
	assign LEDG = ledgOut[7:0];
	// KEY
	negRegister keyReg 	 (clk, reset, keyEn, {28'd0,KEY}, keyOut);
	// HEXS
	negRegister hexReg 	 (clk, reset, hexEn, dataOut2, hexOut); //
	dec2_7seg hex0Converter(hexOut[3:0], HEX0);
	dec2_7seg hex1Converter(hexOut[7:4], HEX1);
	dec2_7seg hex2Converter(hexOut[11:8], HEX2);
	dec2_7seg hex3Converter(hexOut[15:12], HEX3);
	
endmodule


module IO_controller(dataAddr, isLoad, isStore, dataWrtEn, dataMemOutSel, swEn, keyEn, ledrEn, ledgEn, hexEn);

	input[31:0] dataAddr;
	input isLoad;
	input isStore;
	
	output reg dataWrtEn;
	output reg [1:0] dataMemOutSel;
	output reg swEn;
	output reg keyEn;
	output reg ledrEn;
	output reg ledgEn;
	output reg hexEn;
	
	always @(*)
	begin
	// STORE/LOAD?
	if(isLoad) // LOAD
	begin
		case (dataAddr[31:28])
			4'hF: // I/O
			begin
					case (dataAddr[7:0]) // select which I/O
							8'h14:begin
								dataWrtEn			<= 1'b0;
								dataMemOutSel		<= 2'd1;
								swEn 					<= 1'b1;
								keyEn					<= 1'b0;
								ledrEn 				<= 1'b0;
								ledgEn 				<= 1'b0;
								hexEn 				<= 1'b0;
							end
							8'h10:begin
								dataWrtEn			<= 1'b0;
								dataMemOutSel		<= 2'd2;
								swEn 					<= 1'b0;
								keyEn					<= 1'b1;
								ledrEn 				<= 1'b0;
								ledgEn 				<= 1'b0;
								hexEn 				<= 1'b0;
							end
							default:begin
								dataWrtEn			<= 1'b0;
								dataMemOutSel		<= 2'd0;
								swEn 					<= 1'b0;
								keyEn					<= 1'b0;
								ledrEn 				<= 1'b0;
								ledgEn 				<= 1'b0;
								hexEn 				<= 1'b0;
							end
					endcase
			end
			default:begin
				dataWrtEn			<= 1'b0;
				dataMemOutSel		<= 2'd0;
				swEn 					<= 1'b0;
				keyEn					<= 1'b0;
				ledrEn 				<= 1'b0;
				ledgEn 				<= 1'b0;
				hexEn 				<= 1'b0;
			end
		endcase
	end
	else if(isStore) // STORE
	begin
		case (dataAddr[31:28])
			4'hF: // I/O
			begin
				case (dataAddr[7:0]) // select which I/O
						8'h04:begin // LEDR
							dataWrtEn			<= 1'b0;
							dataMemOutSel		<= 2'd0;
							swEn 					<= 1'b0;
							keyEn					<= 1'b0;
							ledrEn 				<= 1'b1;
							ledgEn 				<= 1'b0;
							hexEn 				<= 1'b0;
						end
						8'h08:begin // LEDG
							dataWrtEn			<= 1'b0;
							dataMemOutSel		<= 2'd0;
							swEn 					<= 1'b0;
							keyEn					<= 1'b0;
							ledrEn 				<= 1'b0;
							ledgEn 				<= 1'b1;
							hexEn 				<= 1'b0;
						end
						8'h00:begin // HEX
							dataWrtEn			<= 1'b0;
							dataMemOutSel		<= 2'd0;
							swEn 					<= 1'b0;
							keyEn					<= 1'b0;
							ledrEn 				<= 1'b0;
							ledgEn 				<= 1'b0;
							hexEn 				<= 1'b1;
						end
						default:begin
							dataWrtEn			<= 1'b0;
							dataMemOutSel		<= 2'd0;
							swEn 					<= 1'b0;
							keyEn					<= 1'b0;
							ledrEn 				<= 1'b0;
							ledgEn 				<= 1'b0;
							hexEn 				<= 1'b0;
						end
				endcase
			end
			default:begin
				dataWrtEn			<= 1'b1;
				dataMemOutSel		<= 2'd0;
				swEn 					<= 1'b0;
				keyEn					<= 1'b0;
				ledrEn 				<= 1'b0;
				ledgEn 				<= 1'b0;
				hexEn 				<= 1'b0;
			end
		endcase
	end
	else // not LOAD neither STORE
	begin
		dataWrtEn			<= 1'b0;
		dataMemOutSel		<= 2'd0;
		swEn 					<= 1'b0;
		keyEn					<= 1'b0;
		ledrEn 				<= 1'b0;
		ledgEn 				<= 1'b0;
		hexEn 				<= 1'b0;
	end
end
	
endmodule

module dec2_7seg(input [3:0] num, output [6:0] display);
   assign display = 
	num == 0 ? ~7'b0111111 :
	num == 1 ? ~7'b0000110 :
	num == 2 ? ~7'b1011011 :
	num == 3 ? ~7'b1001111 :
	num == 4 ? ~7'b1100110 :
	num == 5 ? ~7'b1101101 :
	num == 6 ? ~7'b1111101 :
	num == 7 ? ~7'b0000111 :
	num == 8 ? ~7'b1111111 :
	num == 9 ? ~7'b1100111 :
	num == 10 ? ~7'b1110111 :
	num == 11 ? ~7'b1111111 :
	num == 12 ? ~7'b0111001 :
	num == 13 ? ~7'b0111111 :
	num == 14 ? ~7'b1111001 :
	num == 15 ? ~7'b1110001 :
	7'bxxxxxxx;   // Output is a don't care if illegal input
endmodule // dec2_7seg

