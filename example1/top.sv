module top
(
	input CLK,
	output D[7:0],
	output CLK_EN
);
	logic counter[27:0];
	assign D[0] = counter[27];
	assign D[1] = counter[26];
	assign D[2] = counter[25];
	assign D[3] = counter[24];
	assign D[4] = counter[23];
	assign D[5] = counter[22];
	assign D[6] = counter[21];
	assign D[7] = counter[20];
	logic CLK_ENABLE = 1;
	assign CLK_EN = CLK_ENABLE;

	always_ff @(posedge CLK) begin
		counter <= counter - 1;
	end
endmodule
