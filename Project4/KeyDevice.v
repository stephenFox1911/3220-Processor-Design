module KeyDevice(ABUS,DBUS,WE,INTR,CLK,LOCK,KEY,FLUSH,DEBUG);
    parameter BITS;
    parameter BASE;
    input [BITS - 1 : 0] ABUS;
    inout [BITS - 1 : 0] DBUS;
    input WE,CLK,LOCK,FLUSH;
    input [3:0] KEY;
    output INTR;
    output [10:0] DEBUG = {PREV_KEY[3:0], KEY[3:0], IE, OR, RE};
    reg [3:0] PREV_KEY;
    reg IE, OR, RE;

    wire selKey = (ABUS == BASE) && !FLUSH;
    wire rdKey = !WE && selKey;

    wire selKCtrl = (ABUS == BASE + 32'h100) && !FLUSH;
    wire wrKCtrl = WE && selKCtrl;
    wire rdKCtrl = !WE && selKCtrl;
	 
	 
    always @(posedge CLK) begin
	     if (LOCK) begin
	      if (rdKey) begin
                RE <= 1'b0;
                OR <= 1'b0;
            end else if (wrKCtrl) begin
                if (!DBUS[2]) OR <= 0;
                IE <= DBUS[8];
            end
            if (KEY != PREV_KEY) begin
                PREV_KEY <= KEY;
					 if (RE) OR <= 1'b1;
					 else RE <= 1'b1;
				end
        end else begin
            PREV_KEY <= KEY;
            {IE,OR,RE} <= 3'b0;
        end
    end
    assign DBUS = rdKey ? {{(BITS-4){1'b0}}, PREV_KEY} :
                rdKCtrl ? {{(BITS-9){1'b0}}, IE,5'b0,OR,1'b0,RE} :
                {BITS{1'bz}};
    assign INTR = IE;
endmodule
