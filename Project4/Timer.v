module Timer(ABUS, DBUS,WE,CLK,CLK_50);

parameter BITS;
parameter BASE;

input wire [BITS-1:0] ABUS;
inout wire [BITS-1:0] DBUS;
input wire WE,CLK,CLK_50;
//output wire INTR;

wire selCnt = (ABUS==BASE);
wire wrCnt = WE&&selCnt;
wire rdCnt = (!WE)&&selCnt;

wire selLim = (ABUS== (BASE + 4'h4));
wire wrLim = WE&&selLim;
wire rdLim = (!WE)&&selLim;

wire selCtl = (ABUS== (BASE + 'h100));
wire wrCtl = WE&&selCtl;
wire rdCtl = (!WE)&&selCtl;

reg [BITS-1:0] cnt,lim = 0;
reg [8:0] ctl = 0;

wire newclk;
ClkDivider #(5000, 31) divider (.clkIn(CLK_50), .clkOut(newclk));

reg old_clk;
always@(posedge CLK or posedge newclk) begin
	if(CLK) begin
		if(CLK - 1 == old_clk && wrCnt)
			cnt <= DBUS;
	end
	else if(old_clk == CLK) begin
		if(lim != 0 || lim == (cnt + 1))
			cnt <= 0;
		else
			cnt <= cnt + 1'b1;
	end
	
	old_clk <= CLK;
end

always@(posedge CLK) begin
	if(wrLim)
		lim <= DBUS;
end


reg [BITS-1:0] old_cntr;
//ctrl bit2
always@(posedge CLK) begin
		if(wrCtl && DBUS[2] == 0) //writing 0, even if 1 was about to be written
			ctl[2] <= 0;
		else if(ctl[0] == 1 && cnt < old_cntr)
			ctl[2] <= 1;
		
		old_cntr <= cnt;
end

//ctrl bit0
reg [BITS - 1:0] old_cnt;
always@(posedge CLK) begin
	if(wrCtl && DBUS[0] == 0)
		ctl[0] <= 0;
	else if(old_cnt != cnt && cnt < old_cnt)
		ctl[0] <= 1;
		
	old_cnt <= cnt;
end

assign DBUS = rdCtl?{23'd0,ctl}:
				  rdCnt?{cnt}:
				  rdLim?{lim}:
			     {BITS{1'bz}};
						
						  
endmodule