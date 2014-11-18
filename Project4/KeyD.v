module KeyD(ABUS,DBUS,WE,CLK,KEY);

parameter BITS;
parameter BASE;

input wire [BITS-1:0] ABUS;
inout wire [BITS-1:0] DBUS;
input wire WE,CLK;
input wire [3:0] KEY;
//output wire INTR;

wire selData = (ABUS == BASE);
wire rdData = (!WE) && selData;
wire selCtrl = (ABUS == (BASE + 'h100));
wire rdCtrl = (!WE) && selCtrl;

wire [3:0] kdata = KEY;
reg [8:0] kctrl;

//ctrl bit2
reg [3:0] old_kdata;

always@(posedge CLK) begin
		if(selCtrl && WE && DBUS[2] == 0) //writing 0, even if 1 was about to be written
			kctrl[2] <= 0;
		else if(kctrl[0] == 1 && kdata != old_kdata)
			kctrl[2] <= 1;
		
		old_kdata <= kdata;
end

//ctrl bit0
always@(kdata or rdData) begin
	kctrl[0] <= rdData?0:1;
end	


initial begin
	kctrl = 9'b0;
end


assign DBUS = rdData?{28'd0,kdata}:	
				  rdCtrl?{23'd0,kctrl}:
				        {BITS{1'bz}};

endmodule


