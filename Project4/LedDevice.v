module LedDevice(ABUS,DBUS,WE,CLK,LOCK,LED,FLUSH);
  parameter BITS, LBITS, BASE;

  input wire [BITS - 1 : 0] ABUS;
  inout wire [BITS - 1 : 0] DBUS;
  input wire WE, CLK, LOCK, FLUSH;

  reg [LBITS - 1 : 0] val;
  output wire [LBITS - 1 : 0] LED = val;

  wire sel = (ABUS == BASE) && !FLUSH;
  wire wrl = WE && sel;

  always @(posedge CLK) begin
      if (LOCK) begin
        if (wrl) val <= DBUS[LBITS - 1 : 0];
      end else val <= {LBITS{1'b0}};
  end

endmodule
