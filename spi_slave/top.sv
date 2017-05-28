module top
(
	input CLK,
	output CLK_EN,

	input SCK,
	input MOSI,
	input CS,
	output MISO,

	output LED[7:0]
);
	SPI_Slave spi(.CLK(CLK), .SCK(SCK), .MOSI(MOSI), .SSEL(CS), .MISO(MISO), .LED(LED[0]));

	logic CLK_ENABLE = 1;
	assign CLK_EN = CLK_ENABLE;
	
endmodule
