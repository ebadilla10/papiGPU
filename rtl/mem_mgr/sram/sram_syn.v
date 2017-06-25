`timescale 1ns / 1ps

module sram_ctrl(
	input iClock,
	input iReset,

	//Inputs and outputs to controller from using module
	input [21:0] iAddress, //4MBytes addressable
	input [15:0] iData,
	output reg [15:0] oData,
	input iValidRequest,  //Request - address and data valid (if iWrite)
	input iWrite,  //High if iWrite, low if read
	output reg oValidRead = 1'b0, //Request (read or write) complete - data valid if read

	//Outputs to Memory device
	output reg oClock = 1'b0,
	output reg oClockEn = 1'b0,
	output reg oCSN = 1'b0,
	output reg oRASN = 1'b1,
	output reg oCASN = 1'b1,
	output reg oWEn = 1'b1,
	output reg [1:0] oBank = 2'b00,
	output reg oDAMh = 1'b0,
	output reg oDAMl = 1'b0,
	output reg [11:0] oRamMemAddr = 12'b000000000000,
	inout wire [15:0] ioRamData,

	output reg oRegToPinREAD = 1, // TO VERIFY
	output reg oRegToPinWRITE = 1 // TO VERIFY
    );

  parameter MEMORY_ENTRY_SIZE = 16;
  parameter MEMORY_SIZE = 256;
	parameter BYTE_SIZE = 8;

  reg [MEMORY_ENTRY_SIZE-1:0] MemRam [MEMORY_SIZE-1:0];

  always @ (negedge iClock) begin
    if (oValidRead) begin
      oValidRead = 1'b0;
    end else begin
      if (iValidRequest) begin
        if (iWrite) begin
          MemRam [iAddress[7:0]] = iData;
          oValidRead = 1'b1;

          oRegToPinWRITE = 1'b0;
        end else begin
          oData = MemRam [iAddress[7:0]];
          oValidRead = 1'b1;

          oRegToPinREAD = 1'b0;
        end
      end
    end
  end


endmodule
