module HEXD(ABUS,DBUS,WE,CLK,reset,hdata);

parameter BITS;
parameter BASE;

input wire [BITS-1:0] ABUS;
inout wire [BITS-1:0] DBUS;
input wire WE, CLK, reset;
output reg [15:0] hdata;
//output wire INTR;

wire selData = (ABUS == BASE);
wire rdData = (!WE) && selData;
wire wrData = (WE) && selData;


always@(posedge CLK) begin
	if(reset)
		hdata <= 0;
	else if(wrData)
		hdata <= DBUS[15:0];
	
end

assign DBUS = rdData?{16'd0,hdata}:	
				        {BITS{1'bz}};
						  
endmodule
