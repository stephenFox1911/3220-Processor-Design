module SevenSeg(dIn, dOut);
	input  [3:0] dIn;
	output [6:0] dOut;
	assign dOut =
	  (dIn == 4'h0) ? 7'b1000000 :
	  (dIn == 4'h1) ? 7'b1111001 :
	  (dIn == 4'h2) ? 7'b0100100 :
	  (dIn == 4'h3) ? 7'b0110000 :
	  (dIn == 4'h4) ? 7'b0011001 :
	  (dIn == 4'h5) ? 7'b0010010 :
	  (dIn == 4'h6) ? 7'b0000010 :
	  (dIn == 4'h7) ? 7'b1111000 :
	  (dIn == 4'h8) ? 7'b0000000 :
	  (dIn == 4'h9) ? 7'b0010000 :
	  (dIn == 4'hA) ? 7'b0001000 :
	  (dIn == 4'hb) ? 7'b0000011 :
	  (dIn == 4'hc) ? 7'b1000110 :
	  (dIn == 4'hd) ? 7'b0100001 :
	  (dIn == 4'he) ? 7'b0000110 :
	  /*IN == 4'hf*/  7'b0001110 ;
endmodule
