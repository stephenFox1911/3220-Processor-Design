module Timer(ABUS, DBUS, WE, INTR, CLK, LOCK, DEBUG, FLUSH, IRQ);

	parameter BITS, BASE, DIV;

	input [BITS - 1 : 0] ABUS;
	inout [BITS - 1 : 0] DBUS;
	input WE, CLK, LOCK, FLUSH;
	output INTR, IRQ;

	output [7:0] DEBUG = {TCNT[5:0], TCTL[2], TCTL[0]};
	reg [BITS - 1 : 0] TCNT, TLIM, TCTL, count;

	wire selCnt = (ABUS == BASE) && !FLUSH;
	wire wrCnt = WE && selCnt;
	wire rdCnt = !WE && selCnt;

	wire selLim = (ABUS == (BASE + 4)) && !FLUSH;
	wire wrLim = WE && selLim;
	wire rdLim = !WE && selLim;

	wire selCtl = (ABUS == (BASE + 32'h100)) && !FLUSH;
	wire wrCtl = WE && selCtl;
	wire rdCtl = !WE && selCtl;

	always @(posedge CLK) begin
		if (LOCK) begin
			if (wrCnt) TCNT <= DBUS;
			else if (wrLim) TLIM <= DBUS;
			else if (wrCtl) begin
				if (!DBUS[0]) TCTL[0] <= 0;
				if (!DBUS[2]) TCTL[2] <= 0;
			end else if (TCNT == TLIM - 1) begin
				TCNT <= 0;
				if (TCTL[0]) TCTL[2] <= 1;
				else TCTL[0] <= 1;
			end else if (count == DIV - 1) begin
				count <= 0;
				TCNT <= TCNT + 1;
			end else count <= count + 1;
		end else {TCNT, TLIM, TCTL, count} <= 0;
	end

	assign DBUS = rdCnt ? TCNT : rdLim ? TLIM : rdCtl ? TCTL : {BITS{1'bz}};
	assign INTR = 0;
	assign IRQ = TCTL[2];


endmodule
