module HexDevice(ABUS,DBUS,WE,CLK,LOCK,HEX0,HEX1,HEX2,HEX3,FLUSH);
	parameter BITS;
	parameter BASE;
	input wire [BITS - 1:0] ABUS;
	inout wire [BITS - 1:0] DBUS;
	input wire WE,CLK,LOCK,FLUSH;
	output wire [6:0] HEX0,HEX1,HEX2,HEX3;
  
	reg [15:0] hex;

	SevenSeg sevenSeg3 (
		.dIn(hex[15:12]),
		.dOut(HEX3)
	);

	SevenSeg sevenSeg2 (
		.dIn(hex[11:8]),
		.dOut(HEX2)
	);

	SevenSeg sevenSeg1 (
		.dIn(hex[7:4]),
		.dOut(HEX1)
	);

	SevenSeg sevenSeg0 (
		.dIn(hex[3:0]),
		.dOut(HEX0)
	);

	wire selHex = (ABUS == BASE) && !FLUSH;
	wire wrHex = WE && selHex;

	always @(posedge CLK) begin
		if(LOCK) begin 
			if(wrHex) hex <= DBUS[15:0];
		end else hex <= 16'hDEAD;
	end
  
endmodule
