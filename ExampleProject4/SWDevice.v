module SWDevice(ABUS,DBUS,FLUSH,WE,INTR,CLK,LOCK,SW,DEBUG,IRQ);
  parameter BITS;
  parameter BASE;
  parameter DEBOUNCE_CYCLES;
  parameter READYBIT = 0;
  parameter OVERRUNBIT = 2;
  parameter IEBIT = 8;

  input [(BITS-1):0] ABUS;
  inout [(BITS-1):0] DBUS;
  input WE,CLK,LOCK,FLUSH;
  input [9:0] SW;

  output INTR;
  output [12:0] DEBUG = {SW[9:0],IE,OR,RE};
  output IRQ;

  wire selSW = (ABUS == BASE)&& !FLUSH;
  wire rdSW = (!WE) && selSW;

  wire selSCtrl = (ABUS == BASE+32'h100) && !FLUSH;
  wire wrSCtrl = WE && selSCtrl;
  wire rdSCtrl = (!WE) && selSCtrl;

  reg [9:0] prev,switches;
  reg [19:0] counter;
  reg holding,IE,OR,RE;

  always @(posedge CLK) begin
    if(LOCK) begin
      if (rdSW) begin
        RE <= 1'b0;
      end
      else if (wrSCtrl) begin
        if (!DBUS[OVERRUNBIT]) OR <= 0;
        IE <= DBUS[IEBIT];  
      end

      if((prev != SW) && !holding) begin
        prev <= SW;
        counter <= 20'b0;
        holding <= 1'b1;
      end

      if(holding) begin
        counter <= counter+1'b1;
        if(prev != SW) begin
          holding <= 1'b0;
      end
        if(counter == DEBOUNCE_CYCLES) begin
          switches <= prev;
          if (RE) OR <= 1'b1;
          else RE <= 1'b1;
          counter <= 20'b0;
          holding <= 1'b0;
        end
      end
    end	
    else begin
      {holding,IE,OR,RE} <= 4'b0000;
      prev <= SW;
      switches <= SW;
      counter <= 20'b0;
    end
  end
  assign DBUS = rdSW ? {{(BITS-10){1'b0}},switches}:
              rdSCtrl ? {{(BITS-9){1'b0}},IE,5'b0,OR,1'b0,RE} :
              {BITS{1'bz}};
  assign INTR = IE;
  assign IRQ = IE && RE;

endmodule
