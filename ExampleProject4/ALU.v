module ALU(dIn1, dIn2, op1, op2, dOut);
	parameter BIT_WIDTH = 32;
  	
	input [3:0] op1, op2;
	input signed [(BIT_WIDTH - 1) : 0] dIn1, dIn2;
	output reg signed [(BIT_WIDTH - 1) : 0] dOut;
	
	always @(*) begin
		if (op1[1:0] == 2'b10) begin
			if (op2[3]) begin
				if (op2[2]) begin
					case (op2[1:0])
						2'b01: dOut <= dIn1 != 0;	    			//BNEZ
						2'b10: dOut <= dIn1 >= 0;					//BGTEZ
						2'b11: dOut <= dIn1 > 0;  					//BGTZ
						default: dOut <= 32'hffffffff;
					endcase
				end else begin
					case (op2[1:0])
						2'b00: dOut <= 32'd1;		        	//T & TI & BT
						2'b01: dOut <= dIn1 != dIn2;			//NE & NEI & BNE
						2'b10: dOut <= dIn1 >= dIn2;   			//GTE & GTEI & BGTE
						2'b11: dOut <= dIn1 > dIn2;    			//GT & GTI & BGT
					endcase
				end
			end else begin
				if (op2[2]) begin
					case (op2[1:0])
						4'b01: dOut <= dIn1 == 0;				//BEQZ
						4'b10: dOut <= dIn1 < 0;    			//BLTZ
						4'b11: dOut <= dIn1 <= 0;      			//BLTEZ
						default: dOut <= 32'hffffffff;
					endcase
				end else begin
					case (op2[1:0])
						2'b00: dOut <= 32'd0;					//F & FI & BF
						2'b01: dOut <= dIn1 == dIn2;			//EQ & EQI & BEQ
						2'b10: dOut <= dIn1 < dIn2;    			//LT & LTI & BLT
						2'b11: dOut <= dIn1 <= dIn2;   			//LTE & LTEI & BLTE
					endcase
				end
			end
		end else begin
			if (op2[3]) begin
				case (op2[1:0])
					2'b00: dOut <= ~(dIn1 & dIn2);				//NAND & NANDI
					2'b01: dOut <= ~(dIn1 | dIn2);				//NOR & NORI
					2'b10: dOut <= ~(dIn1 ^ dIn2);				//XNOR & XNORI
					2'b11: dOut <= dIn2 << 16;
				endcase
			end else begin
				if (op2[2]) begin
					case (op2[1:0])
						2'b00: dOut <= dIn1 & dIn2;				//AND & ANDI
						2'b01: dOut <= dIn1 | dIn2;				//OR & ORI
						2'b10: dOut <= dIn1 ^ dIn2;				//XOR & XORI
						default: dOut <= 32'hffffffff;
					endcase
				end else begin
					if (op2[0]) dOut <= dIn1 - dIn2;	    			//SUB & SUBI
					else dOut <= dIn1 + (dIn2 << (op1[1] ? 2 : 0));		//ADD & ADDI & LW & SW & JAL
				end
		    end
		end
	end
endmodule
