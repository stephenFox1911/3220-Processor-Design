module Alu (ctrl, rawDataIn1, rawDataIn2, dataOut, cmpOut);
	parameter DATA_BIT_WIDTH = 32;
	parameter CTRL_BIT_WIDTH = 5;
	parameter CMPOUT_BIT_WIDTH = 3;
	
	input  [DATA_BIT_WIDTH - 1: 0] rawDataIn1, rawDataIn2;
	input  [CTRL_BIT_WIDTH - 1: 0] ctrl;
	output reg [DATA_BIT_WIDTH - 1: 0] dataOut;
	
	output reg cmpOut; // true or false

	
	wire signed [DATA_BIT_WIDTH - 1: 0] data1, data2;
	
	assign data1 = rawDataIn1;
	assign data2 = rawDataIn2;

	always @(*)
	begin
		case (ctrl)
		5'b00000:begin // ADD, ADDI, LW, SW
						dataOut <= data1 + data2;
						cmpOut  <= 1'b0;
					end
		5'b00001:begin // SUB, SUBI
						dataOut <= data1 - data2;
						cmpOut  <= 1'b0;
					end
		5'b00100:begin // AND, ANDI
						dataOut <= data1 & data2;
						cmpOut  <= 1'b0;
					end
		5'b00101:begin // OR, ORI
						dataOut <= data1 | data2;
						cmpOut  <= 1'b0;
					end
		5'b00110:begin // XOR, XORI
						dataOut <= data1 ^ data2;
						cmpOut  <= 1'b0;
					end
		5'b01100:begin // NAND, NANDI
						dataOut <= ~(data1 & data2);
						cmpOut  <= 1'b0;
					end
		5'b01101:begin // NOR, NORI
						dataOut <= ~(data1 | data2);
						cmpOut  <= 1'b0;
					end
		5'b01110:begin // XNOR, XNORI
						dataOut <= ~(data1 ^ data2);
						cmpOut  <= 1'b0;
					end
		5'b01011:begin // MVHI
						dataOut <= ((data2 & 32'h0000FFFF) << 16); // load high
						cmpOut  <= 1'b0;
					end
		5'b10000:begin // F, FI
						dataOut <= 32'd0;
						cmpOut  <= 1'b0;
					end
		5'b10001:begin // EQ, EQI
						if(data1 == data2)
						begin
							cmpOut  <= 1'b1;
							dataOut <= 32'd1;
						end
						else
						begin	
							cmpOut  <= 1'b0;
							dataOut <= 32'd0;
						end
					end
		5'b10010:begin // LT, LTI
						if(data1 < data2)
						begin
							cmpOut  <= 1'b1;
							dataOut <= 32'd1;
						end
						else
						begin	
							cmpOut  <= 1'b0;
							dataOut <= 32'd0;
						end
					end
		5'b10011:begin // LTE, LTEI
						if(data1 <= data2)
						begin
							cmpOut  <= 1'b1;
							dataOut <= 32'd1;
						end
						else
						begin	
							cmpOut  <= 1'b0;
							dataOut <= 32'd0;
						end
					end
		5'b11000:begin // T, TI
						dataOut <= 32'd1;
						cmpOut  <= 1'b1;
					end
		5'b11001:begin // NE, NEI
						if(data1 != data2)
						begin
							cmpOut  <= 1'b1;
							dataOut <= 32'd1;
						end
						else
						begin	
							cmpOut  <= 1'b0;
							dataOut <= 32'd0;
						end
					end
		5'b11010:begin // GTE, GTEI
						if(data1 >= data2)
						begin
							cmpOut  <= 1'b1;
							dataOut <= 32'd1;
						end
						else
						begin	
							cmpOut  <= 1'b0;
							dataOut <= 32'd0;
						end
					end
		5'b11011:begin // GT, GTI
						if(data1 > data2)
						begin
							cmpOut  <= 1'b1;
							dataOut <= 32'd1;
						end
						else
						begin	
							cmpOut  <= 1'b0;
							dataOut <= 32'd0;
						end
					end
		5'b10101:begin // BEQZ
						dataOut <= 32'd0;
						if(data1 == 32'd0)
							cmpOut  <= 1'b1;
						else	
							cmpOut  <= 1'b0;
					end
		5'b10110:begin // BLTZ
						dataOut <= 32'd0;
						if(data1[31] == 1'b1)
							cmpOut  <= 1'b1;
						else	
							cmpOut  <= 1'b0;
					end
		5'b10111:begin // BLTEZ
						dataOut <= 32'd0;
						if(data1[31] == 1'b1 || data1 == 32'b0) 
							cmpOut  <= 1'b1;
						else	
							cmpOut  <= 1'b0;
					end
		5'b11101:begin // BNEZ
						dataOut <= 32'd0;
						if(data1[31] != 32'd0) 
							cmpOut  <= 1'b1;
						else	
							cmpOut  <= 1'b0;
					end
		5'b11110:begin // BGTEZ
						dataOut <= 32'd0;
						if(data1[31] == 32'd0 || data1 == 32'd0) 
							cmpOut  <= 1'b1;
						else	
							cmpOut  <= 1'b0;
					end
		5'b11111:begin // BGTZ
						dataOut <= 32'd0;
						if(data1[31] == 32'd0 && data1[30:0] != 32'd0) 
							cmpOut  <= 1'b1;
						else	
							cmpOut  <= 1'b0;
					end
		default:begin
						dataOut <= 32'd0;
						cmpOut  <= 1'b0;
					end
		endcase
	end
	
endmodule