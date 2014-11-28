module DataMemory(ABUS,DBUS,WE,CLK,LOCK,FLUSH);

	parameter MEM_INIT_FILE;
	parameter ADDR_BIT_WIDTH = 32;
	parameter DATA_BIT_WIDTH = 32;
	parameter TRUE_ADDR_BIT_WIDTH = 11;
	parameter N_WORDS = (1 << TRUE_ADDR_BIT_WIDTH);
	
	input [ADDR_BIT_WIDTH - 1 : 0] ABUS;
	inout [DATA_BIT_WIDTH - 1 : 0] DBUS;
	input WE,CLK,LOCK,FLUSH;
						
	wire selMem = !ABUS[28] && !FLUSH;
  	wire wrMem = WE && selMem;
  	wire rdMem = !WE && selMem;

	(* ram_init_file = MEM_INIT_FILE *)
	reg [DATA_BIT_WIDTH - 1 : 0] data [0 : N_WORDS - 1];

	always @(posedge CLK) begin
		if (LOCK && wrMem)
			data[ABUS[TRUE_ADDR_BIT_WIDTH + 2 : 2]] <= DBUS;
	end

	assign DBUS = rdMem ? data[ABUS[TRUE_ADDR_BIT_WIDTH + 2 : 2]] : {DATA_BIT_WIDTH{1'bz}};

endmodule
