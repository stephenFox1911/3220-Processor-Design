module comparator(data1, data2, lt_gt, eq);
	parameter DATA_BIT_WIDTH = 32;

	input [DATA_BIT_WIDTH-1:0] data1, data2;
	output reg lt_gt;
	output reg eq;
	
	always @(*)
	begin
		if(data1 < data2)
		begin
			lt_gt 	<= 1'b0;
			eq 		<= 1'b0;
		end
		else if (data1 > data2)
		begin
			lt_gt 	<= 1'b1;
			eq			<= 1'b0;
		end
		else
		begin
			lt_gt		<= 1'b0;
			eq 		<= 1'b1;
		end
	end
endmodule