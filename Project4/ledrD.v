module ledrD(ABUS,DBUS,WE,CLK,reset,ledrData);

parameter BITS;
parameter BASE;

input wire [BITS-1:0] ABUS;
inout wire [BITS-1:0] DBUS;
input wire WE,CLK,reset;
output reg [9:0] ledrData;
//output wire INTR;

wire selData = (ABUS == BASE);
wire rdData = (!WE) && selData;
wire wrData = (WE) && selData;


always@(posedge CLK) begin
	if(reset)
		ledrData <= 0;
	else if(wrData)
		ledrData <= DBUS[9:0];
end

assign DBUS = rdData?{22'd0,ledrData}:	
				        {BITS{1'bz}};

endmodule
