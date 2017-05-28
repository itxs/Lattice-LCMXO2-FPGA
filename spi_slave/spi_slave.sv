module SPI_Slave
(
	input CLK,
	input SCK,
	input MOSI,
	input SSEL,

	output MISO,
	output LED
);
	//Sync SCK to the FPGA clock using a 3 bits shift register
	reg [2:0] SCKreg;
	always_ff @(posedge CLK) SCKreg <= {SCKreg[1:0], SCK};
	wire SCK_rising_edge = (SCKreg[2:1]==2'b01); //now we can detect SCK rising edges
	wire SCK_falling_edge = (SCKreg[2:1]==2'b10); //and falling edges

	//Same sync SSEL to FPGA clock
	reg [2:0] SSELreg;
	always_ff @(posedge CLK) SSELreg <= {SSELreg[1:0], SSEL};
	wire SSEL_active =		~SSELreg[1]; //SSEL is active low
	wire SSEL_start_msg =	(SSELreg[2:1]==2'b10); //message starts at falling edge
	wire SSEL_end_msg =		(SSELreg[2:1]==2'b01); //message starts at rising edge

	//Same sync MOSI to FPGA clock
	reg [1:0] MOSIreg;
	always_ff @(posedge CLK) MOSIreg <= {MOSIreg[0], MOSI};
	wire MOSI_data = MOSIreg[1];

	//We handle SPI in 8-bits format, so we need a 3 bits counter to count the bits as they come in
	reg [2:0] bit_count;
	reg byte_received;
	reg [7:0] byte_data_received;

	always_ff @(posedge CLK)
		begin
			if(~SSEL_active)
				bit_count <= 3'b000;
			else if(SCK_rising_edge) 
				begin
					bit_count <= bit_count + 3'b001;

					//implement a shift-left register (since we receive the data MSB first)
					byte_data_received <= {byte_data_received[6:0], MOSI_data};
				end
		end

	always_ff @(posedge CLK)
		byte_received <= SSEL_active && SCK_rising_edge && (bit_count==3'b111);

	// we use the LSB of the data received to control an LED
	reg LED = 1;
	always_ff @(posedge CLK)
		if(byte_received) LED <= ~byte_data_received[0];

	reg [7:0] byte_data_sent;
	reg [7:0] cnt;
	always_ff @(posedge CLK)
		if(SSEL_start_msg)
			cnt <= cnt + 8'h1;  // count the messages

	always_ff @(posedge CLK)
	if (SSEL_active)
		begin
			if(SSEL_start_msg)
				byte_data_sent <= cnt; //first byte in a message is the message count
			else if(SCK_falling_edge) 
				begin
					if(bit_count==3'b000)
						byte_data_sent <= 8'h00; //after that we send zeros
					else
						byte_data_sent <= {byte_data_sent[6:0], 1'b0};
				end
		end

	assign MISO = byte_data_sent[7]; //Send MSB first
	//we assume that there is only one slave on the SPI bus
	//so we dont bother with a tri-state buffer for MISO
	//otherwise we would need to tri-state MISO when SSEL in inactive

endmodule // SPI_Slave
