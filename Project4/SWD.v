module SWD(ABUS,DBUS,WE,CLK,CLK_50,SW);

parameter BITS;
parameter BASE;

input wire [BITS-1:0] ABUS;
inout wire [BITS-1:0] DBUS;
input wire WE,CLK, CLK_50;
input wire [9:0] SW;
//output wire INTR;

wire selData = (ABUS == BASE);
wire rdData = (!WE) && selData;
wire selCtrl = (ABUS == BASE + 'h100);
wire rdCtrl = (!WE) && selCtrl;

reg [9:0] sdata;
reg [8:0] sctrl;


reg [10:0] counter = 0;
wire newclk;
ClkDivider #(5000, 31) divider (.clkIn(CLK_50), .clkOut(newclk));


reg [9:0] newSW;

always@(posedge newclk) begin
	if(sdata != SW) begin
		case(counter) 
			10:begin
				sdata <= SW;
				counter <= 0;
			end
			0:begin
				newSW <= SW;
				counter <= counter + 1;
			end
			default:begin
				if(newSW == SW)
					counter <= counter + 1;
				else
					counter <= 0;
			end
		endcase
	end
end

//ctrl bit2
reg [9:0] old_sdata;
always@(posedge CLK) begin
		if(selCtrl && WE && DBUS[2] == 0) //writing 0, even if 1 was about to be written
			sctrl[2] <= 0;
		else if(sctrl[0] == 1 && sdata != old_sdata)
			sctrl[2] <= 1;
		
		old_sdata <= sdata;
end

//ctrl bit0
always@(sdata or rdData) begin
	sctrl[0] <= rdData?0:1;
end	


initial begin
	sctrl <= 9'b0;
	sdata <= SW;
end


assign DBUS = rdData?{22'd0,sdata}:	
				  rdCtrl?{23'd0,sctrl}:
				        {BITS{1'bz}};

endmodule

