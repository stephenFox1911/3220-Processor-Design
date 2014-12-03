module Processor(SW,KEY,CLOCK_50,LEDR,LEDG,HEX0,HEX1,HEX2,HEX3);
    input  [9:0] SW;
    input  [3:0] KEY;
    input  CLOCK_50;
    output [9:0] LEDR;
    output [7:0] LEDG;
    output [6:0] HEX0,HEX1,HEX2,HEX3;

    parameter ADDR_HEX             = 32'hF0000000;
    parameter ADDR_LEDR            = 32'hF0000004;
    parameter ADDR_LEDG            = 32'hF0000008;
    parameter ADDR_KDATA           = 32'hF0000010;
    parameter ADDR_SDATA           = 32'hF0000014;
    parameter ADDR_KCTRL           = 32'hF0000110;
    parameter ADDR_SCTRL           = 32'hF0000114;
    parameter ADDR_TCNT            = 32'hF0000020;
    parameter ADDR_TLIM            = 32'hF0000024;
    parameter ADDR_TCTL			     = 32'hF0000120;

    parameter DBITS                    = 32;
    parameter INST_BIT_WIDTH           = 32;
    parameter START_PC                 = 32'h40;
    parameter REG_INDEX_BIT_WIDTH      = 4;
    parameter IMEM_ADDR_BIT_WIDTH      = 11;
    parameter IMEM_DATA_BIT_WIDTH      = INST_BIT_WIDTH;
    parameter IMEM_PC_BITS_HI          = IMEM_ADDR_BIT_WIDTH + 2;
    parameter IMEM_PC_BITS_LO          = 2;
    parameter MEM_INIT_FILE        		= "stopwatch.mif";
	 
	 parameter IH_ADDRESS			= 32'h10;

    // Wires..
    wire pcWrtEn = 1'b1;
    wire memWrite, jal, alusrc, pcmux, memtoReg, regWrite, branchSel, memWriteSel;
    wire [3:0] nextDrOut;
    wire [4:0] ctrlBitOut;
    wire [7:0] aluControl;
    wire [IMEM_DATA_BIT_WIDTH - 1 : 0] instWord;
    wire [DBITS - 1 : 0] pcIn, pcOut, incrementedPC, aluOut, signExtImm, pcAdderOut, dataMuxOut,
                         sr1Out, sr2Out, aluMuxOut, memDataOut, branchOut, pipePcOut, pipeAluOut, pipeSr2Out;
    wire [DBITS - 1 : 0] abus;
    tri  [DBITS - 1 : 0] dbus;

    wire clk, lock, we, flush;
    PLL PLL_inst (.inclk0 (CLOCK_50),.c0 (clk),.locked (lock));
    wire reset = ~lock;

    // Create PCMUX
    Mux2to1 #(DBITS) pcMux (
      .sel(pcmux),
      .dInSrc1(incrementedPC),
      .dInSrc2(branchOut),
      .dOut(pcIn)
    );

    // This PC instantiation is your starting point
    Register #(DBITS, START_PC) pc (
      .clk(clk),
      .reset(reset),
      .wrtEn(pcWrtEn),
      .dataIn(pcIn),
      .dataOut(pcOut)
    );

    // Create PC Increament (PC + 4)
    PCIncrement pcIncrement (
      .dIn(pcOut),
      .dOut(incrementedPC)
    );

    // Create Instruction Memory
    InstMemory #(MEM_INIT_FILE, IMEM_ADDR_BIT_WIDTH, IMEM_DATA_BIT_WIDTH) instMemory (
      .addr(pcOut[IMEM_PC_BITS_HI - 1 : IMEM_PC_BITS_LO]),
      .dataOut(instWord)
    );

    // Create Controller(SCProcController)
    SCProcController controller (
      .opcode(instWord[IMEM_DATA_BIT_WIDTH - 1 : IMEM_DATA_BIT_WIDTH - 8]),
      .aluControl(aluControl),
      .alusrc(alusrc),
      .branchSel(branchSel),
      .memWriteSel(memWriteSel),
      .ctrlBit(ctrlBitOut),
		.sysWrEn(sysWrenIn),
		.sysRead(sysReadIn),
		.sysRet(sysRetIn)
    );

    // Create SignExtension
    SignExtension #(16, DBITS) signExtension (
      .dIn(instWord[15:0]),
      .dOut(signExtImm)
    );

    // Create pcAdder (incrementedPC + signExtImm << 2)
    PCAdder pcAdder (
      .dIn1(incrementedPC),
      .dIn2(signExtImm),
      .dOut(pcAdderOut)
    );

    // Create Dual Ported Register File
    RegisterFile #(DBITS, REG_INDEX_BIT_WIDTH) dprf (
      .CLK(clk),
      .WE(regWrite),
      .LOCK(lock),
      .DIN(dataMuxOut),
      .DR(nextDrOut),
      .SR1(memWriteSel | branchSel ? instWord[23:20] : instWord[19:16]),
      .SR2(memWriteSel | branchSel ? instWord[19:16] : instWord[15:12]),
      .SR1OUT(sr1Out),
      .SR2OUT(sr2Out)
    );

    // Create AluMux (Between DPRF and ALU)
    Mux2to1 #(DBITS) aluMux (
      .sel(alusrc),
      .dInSrc1(sr2Out),
      .dInSrc2(signExtImm),
      .dOut(aluMuxOut)
    );

    // Create ALU
    ALU alu (
      .dIn1(sr1Out),
      .dIn2(aluMuxOut),
      .op1(aluControl[7:4]),
      .op2(aluControl[3:0]),
      .dOut(aluOut)
    );

	 wire sysWrenIn, sysWrenOut, sysReadIn, sysReadOut, sysRetIn, sysRetOut;
    // Create Pipe Buffer
    PipeBuffer pipeBuffer (
      .clk(clk),
      .rst(reset),
		.IRQ(PCS[0] & IRQ),
      .nextDrIn(sysReadIn ? instWord[19:16] : instWord[23:20]),
      .nextDrOut(nextDrOut),
      .dFromAlu(aluOut),
      .dPipeAluOut(pipeAluOut),
      .sr2FromAlu(sr2Out),
      .dSr2Out(pipeSr2Out),
      .branchIn(pcAdderOut),
      .branchOut(branchOut),
		.IHA(iha_out),
		.IRA(ira_out),
      .pipePcIn(incrementedPC),
      .pipePcOut(pipePcOut),
      .ctrlIn(ctrlBitOut),
      .memtoReg(memtoReg),
      .memWrite(memWrite),
      .regWrite(regWrite),
      .pcMux(pcmux),
      .jal(jal),
      .flush(flush),
		.sysWrenIn(sysWrenIn),	//system reg write enable
		.sysWrenOut(sysWrenOut),
		.sysReadIn(sysReadIn),	//system reg read flag
		.sysReadOut(sysReadOut),
		.sysSelIn(instWord[23:20]),	//select value for reading system regs
		.sysSelOut(sysSel),
		.sysRetIn(sysRetIn),
		.sysRetOut(sysRetOut)
    );

    assign abus = pipeAluOut;
    assign dbus = memWrite ? pipeSr2Out : {DBITS{1'bz}};
	 
	 wire [DBITS - 1: 0] ira_out, iha_out, idn_out;
	 wire [1:0] pcs_out;
	 
	 wire [3:0] sysSel;
	 
	 //write if ie and interrupted, or wsr
	 Register #(DBITS, 0) IRA (
      .clk(clk),
      .reset(reset),
      .wrtEn((sysSel == 2 & sysWrenOut) | (PCS[0] & IRQ)),
      .dataIn(IRQ ? pipePcOut : pipeSr2Out),
      .dataOut(ira_out)
    );
	 
	 //write on wsr
	 Register #(DBITS, IH_ADDRESS) IHA (
      .clk(clk),
      .reset(reset),
      .wrtEn(sysSel == 1 & sysWrenOut),
      .dataIn(pipeSr2Out),
      .dataOut(iha_out)
    );
	 
	 //write if ie and interrupted
	 Register #(DBITS, 0) IDN (
      .clk(clk),
      .reset(reset),
      .wrtEn(PCS[0] & IRQ),
      .dataIn(idn_in),
      .dataOut(idn_out)
    );
	 
	 //write if ie and interrupted, and on reti
	 //bit 1 is oie
	 //bit 0 is ie
	 Register #(2, 2'b11) PCS (
      .clk(clk),
      .reset(reset),
      .wrtEn(sysRetOut | (PCS[0] & IRQ)),
      .dataIn(sysRetOut ? {PCS[1], PCS[1]} : {PCS[0], 1'b0}),		
      .dataOut(pcs_out)
    );
	 
	 wire [DBITS - 1: 0] sysRegOut;
	 Mux4to1 srOut(
		.sel(sysSel),
		.dInSrc1({29'b0, pcs_out}),
		.dInSrc2(iha_out),
		.dInSrc3(ira_out),
		.dInSrc4(idn_out),
		.dOut(sysRegOut)
	 );
	 
	 wire IRQ, IRQ_k, IRQ_sw, IRQ_t;
	 
	 int_ctrl interrupter (
		.clk(clk),
		.IRQ_k(IRQ_k),
		.IRQ_sw(IRQ_sw),
		.IRQ_t(IRQ_t),
		.IRQ(IRQ),		//output is IRQ inputs or'd together
		.IDN(idn_in)	//feeds into IDN register
	 );

    DataMemory #(.MEM_INIT_FILE(MEM_INIT_FILE)) dataMemory (
        .ABUS(abus),
        .DBUS(dbus),
        .WE(memWrite),
        .CLK(clk),
        .LOCK(lock),
        .FLUSH(flush)
    );

    Timer #(.BITS(DBITS), .BASE(ADDR_TCNT), .DIV(10000)) timer (
        .ABUS(abus),
        .DBUS(dbus),
        .WE(memWrite),
        .INTR(),
        .CLK(clk),
        .LOCK(lock),
        .FLUSH(flush),
        .DEBUG(),
		  .IRQ(IRQ_t)
    );

    KeyDevice #(.BITS(DBITS),.BASE(ADDR_KDATA)) key_device(
        .ABUS(abus),
        .DBUS(dbus),
        .WE(memWrite),
        .INTR(),
        .CLK(clk),
        .LOCK(lock),
        .KEY(KEY),
        .FLUSH(flush),
        .DEBUG(),
		  .IRQ(IRQ_k)
    );

   SWDevice #(.BITS(DBITS), .BASE(ADDR_SDATA), .DEBOUNCE_CYCLES(100000)) sw_device(
       .ABUS(abus),
       .DBUS(dbus),
       .WE(memWrite),
       .INTR(),
       .CLK(clk),
       .LOCK(lock),
       .SW(SW),
       .FLUSH(flush),
       .DEBUG(),
		 .IRQ(IRQ_sw)
   );

    HexDevice #(.BITS(DBITS),.BASE(ADDR_HEX)) hex_device (
        .ABUS(abus),
        .DBUS(dbus),
        .WE(memWrite),
        .CLK(clk),
        .LOCK(lock),
        .HEX0(HEX0),
        .HEX1(HEX1),
        .HEX2(HEX2),
        .FLUSH(flush),
        .HEX3(HEX3)
    );

    LedDevice #(.BITS(DBITS), .LBITS(10), .BASE(ADDR_LEDR)) ledr (
        .ABUS(abus),
        .DBUS(dbus),
        .WE(memWrite),
        .CLK(clk),
        .LOCK(lock),
        .FLUSH(flush),
        .LED(LEDR)
    );

    LedDevice #(.BITS(DBITS), .LBITS(8), .BASE(ADDR_LEDG)) ledg (
        .ABUS(abus),
        .DBUS(dbus),
        .WE(memWrite),
        .CLK(clk),
        .LOCK(lock),
        .FLUSH(flush),
        .LED(LEDG)
    );

    // Create dataMux
    Mux4to1 #(DBITS) dataMux (
      .sel({jal & (pcmux | sysReadOut), memtoReg}),	//jal doesn't do anything else, is hijacked by rsr and wsr
      .dInSrc1(pipeAluOut),
      .dInSrc2(dbus),
      .dInSrc3(pipePcOut),   //check
		.dInSrc4(sysRegOut),
      .dOut(dataMuxOut)
    );

endmodule
