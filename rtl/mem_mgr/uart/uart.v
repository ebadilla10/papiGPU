`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:
// Engineer:
//
// Create Date:    18:08:05 07/26/2014
// Design Name:
// Module Name:    high_speed_uart
// Project Name:
// Target Devices:
// Tool versions:
// Description:
// Use for baud rates 230400 or greater - tested up to 2MHz
//
// Dependencies:
//
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
//
//////////////////////////////////////////////////////////////////////////////////
module uart_ctrl(
	input iClock,
	input iReset,

	input iRx,
	input [7:0] oTxByte,
	input iTxReady,

	output reg [7:0] oRxByte,
	output reg oRxReady,
	output reg oRxError,
	output reg oTxSent,
	output reg oTx
    );

	parameter CLOCK_RATE = 32000000; //32MHz
	parameter BAUD_RATE = 921600; //Bit rate to receive at
	//Calculate the divider to get sample clock of <SAMPLE_COUNT> * BAUD RATE * 4 (to get a correct Divider)
	parameter SAMPLE_COUNT = CLOCK_RATE / BAUD_RATE;
	parameter BITS_SAMPLE = 8; //Number of bits to support sample count

	//State machine
	parameter IDLE = 3'b000;
	parameter START = 3'b001;
	parameter BUSY = 3'b010;
	parameter STOP = 3'b011;
	parameter READ = 3'b100;
	parameter FRAME_ERR = 3'b101;


	reg [BITS_SAMPLE-1:0] clk_divide_tx;

	reg sample_clk;  //Use DCM and counter to divide 32MHz / (38400 * 16 * 4) = 13
	reg sample_locked; //Set when sample clock locked

	reg [2:0] bit_counter; //Number of bits received
	reg [BITS_SAMPLE-1:0] sample_counter; //Clock counter to determine sample count

	reg [2:0] rx_state;

	reg rx_1; //Output of first stage sync
	reg rx_bit; //Synced iRx
	wire rx_edge; //Flag change of iRx to adjust timer

	reg [2:0] tx_state;
	reg tx_ready_held;
	reg [7:0] tx_copy;
	reg [2:0] tx_bit_counter; //Number of bits sent
	reg [BITS_SAMPLE-1:0] tx_counter; //Bit Timer for oTx

	assign rx_edge = (~rx_bit & rx_1) | (rx_bit & ~rx_1);

/*
   // DCM_SP: Digital Clock Manager
   //         Spartan-6
   // Xilinx HDL Language Template, version 14.7

   DCM_SP #(
      .CLKDV_DIVIDE(DIVIDER),                   // CLKDV divide value
      .CLKIN_PERIOD(31.25),                  // Input clock period specified in nS
      .CLK_FEEDBACK("1X")                  // Feedback source (NONE, 1X, 2X)
   )
   DCM_SP1 (
		.CLK0(clk1),
      .CLKIN(clk),       // 1-bit input: Clock input
      .CLKFB(clk1),       // 1-bit input: Clock feedback input
      .RST(rst),            // 1-bit input: Active high reset input
      .PSEN(psen),         // 1-bit input: Phase shift enable
      .CLKDV(clk_inter)       // 1-bit output: Divided clock output
   );
   // End of DCM_SP_inst instantiation

	assign psen = 1'b0;
*/

/*
	divider sample_clk_gen #(.DIVIDE(DIVIDER),.DIVIDE_BITS(BITS_DIVIDER), .CLEAR_COUNT(1)) (
    .enable(enable),
    .clk(clk),
    .rst(rst),
    .out1(sample_clk)
    );
*/

	//Sync the iRx bit
	always @(posedge iClock)
	begin
			if (iReset)
			 begin
				rx_1 <= 1'b1;
				rx_bit <= 1'b1;
			 end
			else
			 begin
				rx_1 <= iRx;
				rx_bit <= rx_1;
			 end
	end //always

	//iRx block
	always @(posedge iClock)
	begin
		if (iReset)
		 begin
			rx_state <= IDLE;
			oRxByte <= 8'b0;
			oRxReady <= 0;
			oRxError <= 0;
			bit_counter <= 0;
			sample_counter <= 0;
		 end
		else
		 begin
			case (rx_state)
				IDLE: begin
					//Check if start bit
					bit_counter <= 0;
					sample_counter <= 2; //By the time we start counting the start bit we have missed two
					oRxReady <= 0;
					oRxError <= 0;
					oRxByte <= 8'b0;
					if (~rx_bit)
					 begin
						rx_state <= START;
					 end
					else
					 begin
						rx_state <= IDLE;
					 end
				 end
				START: begin
					bit_counter <= 0;
					oRxReady <= 0;
					oRxError <= 0;
					oRxByte <= 8'b0;
					if (sample_counter == SAMPLE_COUNT/2)
					 begin
						//Half a bit sample offset - check start bit still low
						sample_counter <= 0;
						if (!rx_bit)
						 begin
							rx_state <= BUSY;
						 end
						else
						 begin
							rx_state <= IDLE; //False alarm
						 end
					 end
					else
					 begin
						sample_counter <= sample_counter + 1'b1;
						rx_state <= START;
					 end
				 end //START
				BUSY: begin
					oRxReady <= 0;
					oRxError <= 0;
					if (sample_counter == SAMPLE_COUNT - 1)
					 begin
						//Read in next bit (mask with what we already have)
						oRxByte <= oRxByte | (rx_bit << bit_counter);
						sample_counter <= 0;
						if (bit_counter == 3'b111)
						 begin
							//Completed the byte - check stop bit
							bit_counter <= 0;
							rx_state <= STOP;
						 end
						else
						 begin
							bit_counter <= bit_counter + 1'b1;
							rx_state <= BUSY;
						 end
					 end
					else
					 begin
						oRxByte <= oRxByte;
						rx_state <= BUSY;
						bit_counter <= bit_counter;
						if (rx_edge)
						 begin
							//Adjust sample count at iRx edges
							sample_counter <= SAMPLE_COUNT / 2;
						 end
						else
						 begin
							sample_counter <= sample_counter + 1'b1;
						 end
					 end
				 end //BUSY
				STOP: begin
					oRxReady <= 0;
					oRxError <= 0;
					if (sample_counter == SAMPLE_COUNT - 1)
					 begin
						sample_counter <= 0;
						if (rx_bit == 1'b1)
							rx_state <= READ;
						else if (rx_bit == 1'b0)
							rx_state <= FRAME_ERR;
						else
							rx_state <= STOP;
					 end
					else
					 begin
						sample_counter <= sample_counter + 1'b1;
						rx_state <= STOP;
						oRxByte <= oRxByte;
						bit_counter <= 0;
					 end
					end //STOP
				READ: begin
						oRxError <= 0;
						sample_counter <= 0;
						oRxReady <= 1;
						rx_state <= IDLE;
						bit_counter <= 0;
						oRxByte <= oRxByte;
					end //READ
				FRAME_ERR: begin
						sample_counter <= 0;
						oRxError <= 1;
						oRxReady <= 0;
						rx_state <= IDLE;
						bit_counter <= 0;
						oRxByte <= oRxByte;
					end //FRAME_ERR
				default: begin
						rx_state <= IDLE;
						oRxByte <= 8'b0;
						oRxReady <= 0;
						oRxError <= 0;
						bit_counter <= 0;
						sample_counter <= 0;
					end
			endcase
		 end //not iReset
		end //always

	//tx block
	//Hold the iTxReady line high for one sample_clk period
	/*
	always @(posedge clk)
  	 begin
		if (rst)
		 begin
			clk_divide_tx <= 0;
			tx_ready_held <= 1'b0;
		 end
		else
		 begin
			if (iTxReady)
			 begin
				clk_divide_tx <= 0;
				tx_ready_held <= 1'b1;
			 end
			else
			 begin
				if (tx_ready_held)
				 begin
					if (clk_divide_tx == SAMPLE_COUNT)
					 begin
						clk_divide_tx <= 0;
						tx_ready_held <= 0;
					 end
					else
					 begin
						clk_divide_tx <= clk_divide_tx + 1'b1;
						tx_ready_held <= 1'b1;
					 end
				 end
				else
				 begin
					clk_divide_tx <= 0;
					tx_ready_held <= 1'b0;
				 end
			 end
		 end
	 end
*/
	//TX the byte
	always @(posedge iClock)
	 begin
		if (iReset)
		 begin
			tx_state <= IDLE;
			tx_copy <= 0;
			oTx <= 1'b1;
			tx_counter <= 0;
			tx_bit_counter <= 0;
		 end
		else
		 begin
			case (tx_state)
				IDLE: begin
					tx_counter <= 0;
					tx_bit_counter <= 0;
					oTxSent <= 1'b0;
					if (iTxReady)
					 begin
						tx_copy <= oTxByte;
						oTx <= 1'b0; //Set start bit
						tx_state <= START;
						end
					else
					 begin
						tx_state <= IDLE;
						oTx <= 1'b1;
						tx_copy <= 0;
					 end
					end
				START: begin
					if (tx_counter == SAMPLE_COUNT - 1)
					 begin //set the first bit
						oTx <= tx_copy[tx_bit_counter];
						tx_bit_counter <= tx_bit_counter + 1'b1; //Set bit counter to point to next bit
 						tx_counter <= 0;
						tx_state <= BUSY;
						tx_copy <= tx_copy;
					 end
					else
					 begin
						tx_counter <= tx_counter + 1'b1;
						tx_state <= START;
						tx_bit_counter <= tx_bit_counter;
						tx_copy <= tx_copy;
						oTx <= 1'b0;
					 end
					end
				BUSY: begin
					tx_copy <= tx_copy;
					if (tx_counter == SAMPLE_COUNT - 1)
					 begin
						tx_counter <= 0;
						if (tx_bit_counter == 0)
						 begin //Sent all 8 bits
							tx_state <= STOP;
							oTx <= 1'b1;
							tx_bit_counter <= tx_bit_counter;
						 end
						else
						 begin //Send the next bit
							oTx <= tx_copy[tx_bit_counter];
							tx_state <= BUSY;
							tx_bit_counter <= tx_bit_counter + 1'b1;
						 end
					 end //counter == SAMPLE_COUNT - 1
					else
					 begin
						oTx <= oTx;
						tx_counter <= tx_counter + 1'b1;
						tx_bit_counter <= tx_bit_counter;
						tx_state <= BUSY;
					 end
					end //BUSY
				STOP: begin
					tx_copy <= 0;
					tx_bit_counter <= 0;
					oTx <= 1'b1;
					if (tx_counter == SAMPLE_COUNT - 1)
					 begin
						tx_counter <= 0;
						oTxSent <= 1'b1;
						tx_state <= IDLE; //Done
					 end
					else
					 begin
						tx_state <= STOP;
						tx_counter <= tx_counter + 1'b1;
					 end
				 end
			endcase
		 end //if
	 end //always

endmodule
