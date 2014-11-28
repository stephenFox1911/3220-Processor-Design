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
      .ctrlBit(ctrlBitOut)
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

    // Create Pipe Buffer
    PipeBuffer pipeBuffer (
      .clk(clk),
      .rst(reset),
      .nextDrIn(instWord[23:20]),
      .nextDrOut(nextDrOut),
      .dFromAlu(aluOut),
      .dPipeAluOut(pipeAluOut),
      .sr2FromAlu(sr2Out),
      .dSr2Out(pipeSr2Out),
      .branchIn(pcAdderOut),
      .branchOut(branchOut),
      .pipePcIn(incrementedPC),
      .pipePcOut(pipePcOut),
      .ctrlIn(ctrlBitOut),
      .memtoReg(memtoReg),
      .memWrite(memWrite),
      .regWrite(regWrite),
      .pcMux(pcmux),
      .jal(jal),
      .flush(flush)
    );

    assign abus = pipeAluOut;
    assign dbus = memWrite ? pipeSr2Out : {DBITS{1'bz}};

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
        .DEBUG()
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
        .DEBUG()
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
       .DEBUG()
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
    Mux3to1 #(DBITS) dataMux (
      .sel({jal & pcmux, memtoReg}),
      .dInSrc1(pipeAluOut),
      .dInSrc2(dbus),
      .dInSrc3(pipePcOut),   //check
      .dOut(dataMuxOut)
    );

endmodule
