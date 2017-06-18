`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:
// Engineer:
//
// /Create Date:    19:36:00 07/27/2014
// Design Name:
// Module Name:    memory_controller
// Project Name:
// Target Devices:
// Tool versions:
// Description:
// A memory controller for a MT48LC16M4A2-7E 64Mbit SDRAM as 4Mb x 16bits, organised as 4096 rows, 256 cols and 4 banks
// This is a dumb controller in that only one request can be outstanding at any one time, i.e. requests cannot be pipelined
// All inputs should be sync to the input clock. Address and data (if write) should be valid for the posedge of iClock that req is high.
// oValidRead is high when the request is complete and valid data is output (if a read) and another request can be sent

// Dependencies:
//
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
//
//////////////////////////////////////////////////////////////////////////////////
module sram_ctrl(
	input iClock,
	input iReset,

	//Inputs and outputs to controller from using module
	input [21:0] iAddress, //4MBytes addressable
	inout [15:0] ioData,
	input iValidRequest,  //Request - address and data valid (if iWrite)
	input iWrite,  //High if iWrite, low if read
	output reg oValidRead = 1'b0, //Request (read or write) complete - data valid if read

	//Outputs to Memory device
	output reg oClock,
	output reg oClockEn,
	output reg oCSN = 1'b0,
	output reg oRASN = 1'b1,
	output reg oCASN = 1'b1,
	output reg oWEn = 1'b1,
	output reg [1:0] oBank,
	output oDAMh,
	output oDAMl,
	output reg [11:0] oRamMemAddr,
	inout [15:0] ioRamData,

	output reg oRegToPinREAD = 1, // TO VERIFY
	output reg oRegToPinWRITE = 1 // TO VERIFY
    );

	parameter REFRESH_PERIOD_CNT=490; //Need a refresh cycle every 500 clks (15.625us)
	parameter RESET_DELAY_CNT=3200; //Delay needed from reset
	parameter REFRESH_TIME_RFC=6; //Time taken to do an auto refresh 66ns ( just over 2 clocks)
	parameter PRECHARGE_TIME_RP=1; //Precharge time 20ns -> 1clk
	parameter MODE_REGISTER_TIME_MRD=2; //Load mode register time - 2 clks
	parameter ACTIVE_TIME_RCD=1; //Time taken to make a row active 15ns -> 1clk
	parameter MODE_REGISTER = 12'b001000100000; //Write burst=1, Std Op, CAS=2, Seq, BL=1 (no burst)
	parameter ZERO_ADDR = 12'b000000000000; //Default Addr line
	parameter ZERO_CAS = 12'b010000000000; //A10 = high all banks pre-charged
	parameter PRECHARGE_ALL = 12'b010000000000; //A10 = high all banks pre-charged
	parameter PRECHARGE_SEL = 12'b000000000000; //A10 = low selected banks pre-charged
	parameter AUTO_PRECHARGE = 4'b0100; //A10 = high auto pre-charge row after op
	parameter NO_AUTO_PRECHARGE = 4'b0000; //A10 = low no auto pre-charge, row remains active
	parameter CAS_LATENCY = 2; //two clock cycle CAS latency

	//Initialisation state machine
	parameter INIT_POST_RESET = 4'b0000;
	parameter INIT_CLKE = 4'b0001; //oClockEn = high
	parameter INIT_NOP = 4'b0010; //oCSN = Low, oRASN, oCASN, oWEn high
	parameter INIT_PRECHARGE_ALL = 4'b0011; //oRASN=0, oCASN=1, oWEn=0
	parameter INIT_REFRESH_1 = 4'b0100; //oRASN=0, oCASN=0, oWEn=1
	parameter INIT_REFRESH_2 = 4'b0101; //oRASN=0, oCASN=0, oWEn=1
	parameter INIT_LMR = 4'b0110; //Load mode register - oRASN=0, oCASN=0, oWEn=0
	parameter INIT_LMR_NOP = 4'b0111; //Load mode register delay NOP
	parameter INIT_COMPLETE = 4'b1000; //oCSN = Low, oRASN, oCASN, oWEn high

	//Normal Op State machine states
	parameter IDLE = 3'b000;
	parameter ACTIVE_ROW = 3'b001; //oRASN=0,oCASN=1,oWEn=1
	parameter READING = 3'b010; //oRASN=1,oCASN=0,oWEn=1
	parameter WRITING = 3'b011; //oRASN=1,oCASN=0,oWEn=0
	parameter PRECHARGING = 3'b100; //oRASN=0,oCASN=1,oWEn=0
	parameter REFRESHING = 3'b101; //oRASN=0. oCASN=0, oWEn=1
	parameter INIT = 3'b110; //See init state machine
	parameter ROW_ACTIVE = 3'b111; //Row is active - can read or write


	parameter NO_REQ = 2'b00;
	parameter READ_REQ = 2'b01;
	parameter WRITE_REQ = 2'b10;

	wire enable;
	reg init_enable;
	wire refresh_time;
	wire init_time;
	reg [3:0] init_state = INIT_POST_RESET;
	reg [2:0] op_state = IDLE;
	reg [2:0] state_clk_count = 3'b000;
	reg [1:0] req_in_prog = 2'b00; //Handling a request - cleared when oValidRead sent
	reg [21:0] addr_req = 22'h000000; //latched addr
	reg [15:0] data_req = 16'h0000; //latched data if write
	wire row_cmp; //Set if addr change
	wire row_change; //Set if there is a change of row from last time (and so needs a pre-charge - active cycle)
	reg row_diff = 1'b0; //Latched change in row

	reg refresh_req = 1'b0; //Refresh is required or in progress

	reg [1:0] active_waiting = 2'b00;

	divider #(.DIVIDE(REFRESH_PERIOD_CNT),.DIVIDE_BITS(9),.CLEAR_COUNT(1),.CLEAR_BITS(1)) refresh_clk (
    .enable(enable),
    .iClock(iClock),
    .iReset(iReset),
    .out1(refresh_time)
    );

	divider #(.DIVIDE(RESET_DELAY_CNT),.DIVIDE_BITS(12),.CLEAR_COUNT(1),.CLEAR_BITS(1)) init_clk (
    .enable(init_enable),
    .iClock(iClock),
    .iReset(iReset),
    .out1(init_time)
    );

	assign enable = 1'b1;
	//If a read req, drive data out from memory, otherwise z
	assign ioData = (!iWrite) ? ioRamData : 16'bz;
	assign ioRamData = (iWrite) ? ioData : 16'bz;
	assign row_cmp_fail = iValidRequest && (addr_req[21:8] != iAddress[21:8]);
	assign row_change = row_diff || row_cmp_fail;
	assign oDAMh = 1'b0; //not used
	assign oDAMl = 1'b0; //not used

  wire SRAMClock = !iClock;
	always @ ( * ) begin
		oClock = SRAMClock;
	end

	//Set long lived flags
	always @(posedge iClock)
	 begin
		if (iReset)
		 begin
			req_in_prog <= NO_REQ;
			refresh_req <= 1'b0;
			row_diff <= 1'b0;
			addr_req <= 21'b0;
		 end
		else
		 begin
			if (iValidRequest) //new request
			 begin
				if ((op_state == ACTIVE_ROW || op_state == READING || op_state == WRITING) && row_cmp_fail)
				 begin
					//Change of row address
					row_diff <= 1'b1;
				 end
				else
				 begin
					row_diff <= 1'b0;
				 end
				addr_req <= iAddress;
				if (iWrite)
				 begin
					req_in_prog <= WRITE_REQ;
					data_req <= ioData;
				 end
				else
				 begin
					req_in_prog <= READ_REQ;
					data_req <= 0;
				 end
			 end
			else if (op_state == READING || op_state == WRITING) //request being worked on - clear state ready for next
			 begin
				req_in_prog <= NO_REQ;
				addr_req <= addr_req; //Remember last address
				data_req <= data_req;
				row_diff <= row_diff;
			 end
			else
			 begin
				req_in_prog <= req_in_prog;
				addr_req <= addr_req;
				data_req <= data_req;
				if (op_state == PRECHARGING)
				 begin
					row_diff <= 1'b0; //Clear the fact that the row has changed as the row has been closed
				 end
				else
				 begin
					row_diff <= row_diff;
				 end
			 end
			if (refresh_time) //time for a refresh
			 begin
				refresh_req <= 1'b1;
			 end
			else if (op_state == REFRESHING || init_state != INIT_COMPLETE) //refresh under way or we can ignore
			 begin
				refresh_req <= 1'b0;
			 end
			else
			 begin
				refresh_req <= refresh_req;
			 end
		 end
	 end

	//Initialisation and operational block
	always @(posedge iClock)
	 begin
		if (iReset)
		 begin
			init_enable <= 0;
			init_state <= INIT_POST_RESET;
			op_state <= IDLE;
			oClockEn <= 1'b0;
			oCSN <= 1'b1;
			oRASN <= 1'b1;
			oCASN <= 1'b1;
			oWEn <= 1'b1;
			state_clk_count <= 3'b000;
			oRamMemAddr <= ZERO_ADDR;
			oBank <= 2'b00;
			oValidRead <= 1'b0;
		 end
		else
		 begin
			case (init_state)
				INIT_POST_RESET: begin
					init_enable <= 1'b1; //Start init counter
					init_state <= INIT_CLKE;
					//default all other signals
					op_state <= IDLE;
					oClockEn <= 1'b0;
					oCSN <= 1'b1;
					oRASN <= 1'b1;
					oCASN <= 1'b1;
					oWEn <= 1'b1;
					state_clk_count <= 3'b000;
					oRamMemAddr <= ZERO_ADDR;
					oBank <= 2'b00;
					oValidRead <= 1'b0;
				  end
				INIT_CLKE : begin
					init_enable <= 1'b1; //Start init counter
					init_state <= INIT_NOP;
					oClockEn <= 1'b1; //Enable clk in
					//default all other signals
					op_state <= IDLE;
					oCSN <= 1'b1;
					oRASN <= 1'b1;
					oCASN <= 1'b1;
					oWEn <= 1'b1;
					state_clk_count <= 3'b000;
					oRamMemAddr <= ZERO_ADDR;
					oBank <= 2'b00;
					oValidRead <= 1'b0;
				 end
				INIT_NOP: begin //oCSN = Low, oRASN, oCASN, oWEn high
					init_enable <= 1'b1; //Start init counter
					init_state <= INIT_PRECHARGE_ALL;
					oClockEn <= 1'b1;
					oCSN <= 1'b0;
					oRASN <= 1'b1;
					oCASN <= 1'b1;
					oWEn <= 1'b1;
					op_state <= IDLE;
					state_clk_count <= 3'b000;
					oRamMemAddr <= ZERO_ADDR;
					oBank <= 2'b00;
					oValidRead <= 1'b0;
				 end
				INIT_PRECHARGE_ALL : begin //Wait until init time is up and then do a pre-charge
					oClockEn <= 1'b1;
					oCSN <= 1'b0;
					oValidRead <= 1'b0;
					op_state <= IDLE;
					oBank <= 2'b00;
					state_clk_count <= 3'b000;
					if (init_time == 1'b0)
						begin
							//Do another NOP
							init_enable <= 1'b1;
							init_state <= INIT_PRECHARGE_ALL;
							oRASN <= 1'b1;
							oCASN <= 1'b1;
							oWEn <= 1'b1;
							op_state <= IDLE;
							oRamMemAddr <= ZERO_ADDR;
						end
					else
						//Precharge all - oRASN=0, oCASN=1, oWEn=0
						begin
							init_enable <= 1'b0; //Dont need init timer any more - turn it off
							init_state <= INIT_REFRESH_1; //Next state
							oRASN <= 1'b0;
							oCASN <= 1'b1;
							oWEn <= 1'b0;
							oRamMemAddr <= PRECHARGE_ALL;
						end
					end
				INIT_REFRESH_1 : begin
					oClockEn <= 1'b1;
					oCSN <= 1'b0;
					init_enable <= 1'b0;
					oValidRead <= 1'b0;
					op_state <= IDLE;
					oBank <= 2'b00;
					oRamMemAddr <= ZERO_ADDR;
					if (state_clk_count == 3'b001)
					 begin
							//Do the first refresh
							init_state <= INIT_REFRESH_1;
							//oRASN=0, oCASN=0, oWEn=1
							oRASN <= 1'b0;
							oCASN <= 1'b0;
							oWEn <= 1'b1;
							state_clk_count <= state_clk_count + 1'b1;
					 end
					else if (state_clk_count == (REFRESH_TIME_RFC))
					 begin
							//Do the second refresh after the first has completed
							init_state <= INIT_REFRESH_2;
              // NOP
							oRASN <= 1'b1;
							oCASN <= 1'b1;
							oWEn <= 1'b1;
							state_clk_count <= 3'b000;
					 end
					else
					 begin
							//Do a NOP
							init_state <= INIT_REFRESH_1;
							oRASN <= 1'b1;
							oCASN <= 1'b1;
							oWEn <= 1'b1;
							state_clk_count <= state_clk_count + 1'b1;
					 end
				 end
				INIT_REFRESH_2 : begin
					oClockEn <= 1'b1;
					oCSN <= 1'b0;
					init_enable <= 1'b0;
					oValidRead <= 1'b0;
					op_state <= IDLE;
					oBank <= 2'b00;
					oRamMemAddr <= ZERO_ADDR;

					if (state_clk_count == 3'b000)begin
					 //oRASN=0, oCASN=0, oWEn=1
					 init_state <= INIT_REFRESH_2;
					 oRASN <= 1'b0;
					 oCASN <= 1'b0;
					 oWEn <= 1'b1;
					 state_clk_count <= state_clk_count + 1'b1;
					end
					else if (state_clk_count == REFRESH_TIME_RFC)
					 begin
							//Load mode register after refresh has completed
							init_state <= INIT_LMR;
							oRASN <= 1'b0;
							oCASN <= 1'b0;
							oWEn <= 1'b0;
							oRamMemAddr <= MODE_REGISTER;
							state_clk_count <= 3'b000;
					 end
					else
					 begin
							init_state <= INIT_REFRESH_2;
							//Do a NOP for three clocks
							oRASN <= 1'b1;
							oCASN <= 1'b1;
							oWEn <= 1'b1;
							state_clk_count <= state_clk_count + 1'b1;
					 end
				 end
				INIT_LMR: begin //Wait MRD
					oClockEn <= 1'b1;
					oCSN <= 1'b0;
					init_enable <= 1'b0;
					oValidRead <= 1'b0;
					op_state <= IDLE;
					oBank <= 2'b00;
					oRamMemAddr <= ZERO_ADDR;
					oRASN <= 1'b1;
					oCASN <= 1'b1;
					oWEn <= 1'b1;
					if (state_clk_count == MODE_REGISTER_TIME_MRD)
					 begin
							//Device is now ready for use
							init_state <= INIT_COMPLETE;
							state_clk_count <= 3'b000;
					 end
					else
					 begin
							init_state <= INIT_LMR;
							//Wait for tMRD
							state_clk_count <= state_clk_count + 1'b1;
					 end
				 end
				INIT_COMPLETE: begin
					oClockEn <= 1'b1;
					oCSN <= 1'b0;
					init_enable <= 1'b0;
					init_state <= INIT_COMPLETE;
					//Do Normal Op state machine
					case (op_state)
						IDLE: begin
							state_clk_count <= 3'b000;
							oValidRead <= 1'b0;
							if (iValidRequest || (req_in_prog != NO_REQ && !oValidRead))
							 begin
								//New request
								//Activate row
								//oRASN=0,oCASN=1,oWEn=1
								oRASN <= 1'b0;
								oCASN <= 1'b1;
								oWEn <= 1'b1;
								op_state <= ACTIVE_ROW;
								if (iValidRequest)
								 begin
									//Take row addr from input
									oRamMemAddr <= iAddress[19:8];
									oBank <= iAddress[21:20];
								 end
								else
								 begin
									//Take row addr from latched input
									oRamMemAddr <= addr_req[19:8];
									oBank <= addr_req[21:20];
								 end
							 end
							else if (refresh_time || refresh_req)
							 begin
								//Do a refresh cycle
								//oRASN=0, oCASN=0, oWEn=1
								oRASN <= 1'b0;
								oCASN <= 1'b0;
								oWEn <= 1'b1;
								op_state <= REFRESHING;
								oRamMemAddr <= ZERO_ADDR;
								oBank <= 2'b00;
							 end
							else
							 begin
								//NOP
								oRASN <= 1'b1;
								oCASN <= 1'b1;
								oWEn <= 1'b1;
								op_state <= IDLE;
								oRamMemAddr <= ZERO_ADDR;
								oBank <= 2'b00;
							 end
						 end
						ACTIVE_ROW : begin
							state_clk_count <= 3'b000;
							if (refresh_time || refresh_req) //Refresh takes priority
							 begin
								//Close row and do a refresh cycle
								//oRASN=0,oCASN=1,oWEn=0
								oRASN <= 1'b0;
								oCASN <= 1'b1;
								oWEn <= 1'b0;
								op_state <= PRECHARGING;
								oRamMemAddr <= PRECHARGE_ALL;
								oBank <= 2'b00;
								oValidRead <= 1'b0;
							 end
							else if (iValidRequest || (req_in_prog != NO_REQ))
							 begin
								if (row_change)
								 begin
									//Cant process the request in this state - close the current row
									oRASN <= 1'b0;
									oCASN <= 1'b1;
									oWEn <= 1'b0;
									op_state <= PRECHARGING;
									oRamMemAddr <= PRECHARGE_ALL;
									oBank <= 2'b00;
									oValidRead <= 1'b0;
								 end
								else
								 begin

                  if (active_waiting == 2'b10) begin

                   active_waiting <= 2'b00;
									 //Read / write command
									 //oRASN=1,oCASN=0,
									 oRASN <= 1'b1;
									 oCASN <= 1'b0;
									 if ((iValidRequest && iWrite) || (req_in_prog == WRITE_REQ))
									  begin
										 oWEn <= 1'b0;
										 op_state <= WRITING; //Device remains in active state
										 oValidRead <= 1'b1; //Request completed
									  end
									 else //read req
									  begin
										 oWEn <= 1'b1;
										 op_state <= READING;
										 //oValidRead <= 1'b0;
									  end
									 if (iValidRequest)
									  begin
										 //Take col addr from input
										 oRamMemAddr <= {NO_AUTO_PRECHARGE, iAddress[7:0]};
										 oBank <= iAddress[21:20];
									  end
									 else
									  begin
										 //Take col addr from latched input
										 oRamMemAddr <= {NO_AUTO_PRECHARGE, addr_req[7:0]};
										 oBank <= addr_req[21:20];
									  end

                   end // if active_waiting
									 else begin
                    op_state <= ACTIVE_ROW;
										active_waiting <= active_waiting + 1;
                    // Set NOP
										oRASN <= 1'b1;
										oCASN <= 1'b1;
										oWEn <= 1'b1;
									 end

								 end //Do Read / write
							 end //Do iValidRequest
							else
							 begin
								//NOP
								oRASN <= 1'b1;
								oCASN <= 1'b1;
								oWEn <= 1'b1;
								op_state <= ACTIVE_ROW;
								oRamMemAddr <= ZERO_ADDR;
								oBank <= 2'b00;
								oValidRead <= 1'b0;
							 end
						 end
						WRITING : begin
						  oRegToPinWRITE <= 1'b0; // TO VERIFY
							//Single NOPs - this could be done without a NOP to increase write performance (i.e. remove this state completely)
							oRASN <= 1'b1;
							oCASN <= 1'b1;
							oWEn <= 1'b1;
							               // oRamMemAddr <= ZERO_ADDR;
							oBank <= 2'b00;
							op_state <= ACTIVE_ROW;
							state_clk_count <= 3'b000;
							oValidRead <= 1'b0;
						 end
						READING : begin
						  oRegToPinREAD <= 1'b0; // TO VERIFY
							//NOPs while waiting
							oRASN <= 1'b1;
							oCASN <= 1'b1;
							oWEn <= 1'b1;
							              // oRamMemAddr <= ZERO_ADDR;
							oBank <= 2'b00;
							if (state_clk_count == CAS_LATENCY - 1)
							 begin
								//Data should be valid by next posedge of iClock - assert oValidRead now
								oValidRead <= 1'b1;
								op_state <= READING;
								state_clk_count <= state_clk_count + 1'b1;
							 end
							else if (state_clk_count == CAS_LATENCY)
							 begin
								//Read now complete
								op_state <= ACTIVE_ROW;
								state_clk_count <= 0;
								oValidRead <= 1'b0;
							 end
							else
							 begin
								//Wait for CAS latency to complete
								oValidRead <= 1'b0;
								op_state <= READING;
								state_clk_count <= state_clk_count + 1'b1;
							 end
						 end
						PRECHARGING : begin //oRASN=0,oCASN=1,oWEn=0
							//Single NOP
							oRASN <= 1'b1;
							oCASN <= 1'b1;
							oWEn <= 1'b1;
							op_state <= IDLE;
							oRamMemAddr <= ZERO_ADDR;
							oBank <= 2'b00;
							oValidRead <= 1'b0;
						 end
						REFRESHING : begin //oRASN=0. oCASN=0, oWEn=1
							oValidRead <= 1'b0;
							oBank <= 2'b00;
							oRamMemAddr <= ZERO_ADDR;
							//NOP
							oRASN <= 1'b1;
							oCASN <= 1'b1;
							oWEn <= 1'b1;
							if (state_clk_count == (REFRESH_TIME_RFC - 1))
							 begin
									op_state <= IDLE;
									state_clk_count <= 3'b000;
							 end
							else
							 begin
									op_state <= REFRESHING;
									state_clk_count <= state_clk_count + 1'b1;
							 end
						 end
						default : begin
							state_clk_count <= 3'b000;
							oValidRead <= 1'b0;
							//NOP
							oRASN <= 1'b1;
							oCASN <= 1'b1;
							oWEn <= 1'b1;
							op_state <= IDLE;
							oRamMemAddr <= ZERO_ADDR;
							oBank <= 2'b00;
						 end
					endcase
				 end
				default : begin
					init_state <= INIT_COMPLETE;
					init_enable <= 1'b1;
					oClockEn <= 1'b1;
					oCSN <= 1'b0;
					oRASN <= 1'b1;
					oCASN <= 1'b1;
					oWEn <= 1'b1;
					op_state <= IDLE;
					state_clk_count <= 3'b000;
					oRamMemAddr <= ZERO_ADDR;
					oBank <= 2'b00;
				 end
			endcase
		 end
	 end

endmodule


module divider(
	 input enable,
	 input iClock,
	 input iReset,
	 output reg out1 = 1'b0
	 );

	 parameter DIVIDE_BITS=4;
	 parameter DIVIDE=10;
	 parameter CLEAR_BITS=4;
	 parameter CLEAR_COUNT=9;

	 reg [DIVIDE_BITS-1:0] counter;
	 reg [CLEAR_BITS-1:0] clear_counter;

	 always @(posedge iClock or posedge iReset)
	 begin
		//Clear counter and output on reset or not enable
		if (iReset)
		 begin
			out1 <= 0;
			counter <= 0;
			clear_counter <= 0;
		 end
		else if (enable == 1'b1)
		 begin
			//Check if clear count reached
			if (out1 == 1'b1)
			 begin
					if (clear_counter == CLEAR_COUNT-1)
					 begin
						out1 <= 1'b0;
						clear_counter <= 0;
					 end
					else
					 begin
						out1 <= out1;
						clear_counter <= clear_counter + 1'b1;
					 end
			 end
			else if (counter == DIVIDE)
				//Check if max count is reached
				 begin
					out1 <= 1'b1;
					counter <= 0;
				 end
			else
			 begin
 				 out1 <= out1;
				 counter <= counter + 1'b1;
			 end
		 end //if enabled
		else
		 begin
			out1 <= 0;
			counter <= 0;
			clear_counter <= 0;
		 end

	end //always

endmodule
