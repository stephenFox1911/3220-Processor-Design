module ledgD(ABUS,DBUS,WE,CLK,reset,ledgData);

parameter BITS;
parameter BASE;

input wire [BITS-1:0] ABUS;
inout wire [BITS-1:0] DBUS;
input wire WE,CLK,reset;
output reg [7:0] ledgData;
//output wire INTR;

wire selData = (ABUS == BASE);
wire rdData = (!WE) && selData;
wire wrData = (WE) && selData;


always@(posedge CLK) begin
	if(reset)
		ledgData <= 0;
	else if(wrData)
		ledgData <= DBUS[7:0];
end

assign DBUS = rdData?{24'd0,ledgData}:	
				        {BITS{1'bz}};
						  
endmodule
