`timescale 1ns / 1ps

`include "./mem_ctrl/mem_ctrl.v"
`include "./sram/sram.v"
`include "./uart/uart.v"

module mem_mgr (
  input iClock,
	input iReset,

  // Outputs to Graphics Pipeline
  output reg        oEnable = 1'b0,
  output reg        oInitObj = 1'b0,
  output reg        oInitVtx = 1'b0,
  output reg [15:0] oCamVerX,
  output reg [15:0] oCamVerY,
  output reg [15:0] oCamVerZ,
  output reg [15:0] oCamDc,
  output reg [15:0] oCosRoll,
  output reg [15:0] oCosPitch,
  output reg [15:0] oCosYaw,
  output reg [15:0] oSenRoll,
  output reg [15:0] oSenPitch,
  output reg [15:0] oSenYaw,
  output reg [15:0] oScaleX,
  output reg [15:0] oScaleY,
  output reg [15:0] oScaleZ,
  output reg [15:0] oTranslX,
  output reg [15:0] oTranslY,
  output reg [15:0] oTranslZ,
  output reg [15:0] oVertexX,
  output reg [15:0] oVertexY,
  output reg [15:0] oVertexZ,

  // Outputs to SRAM device
	output reg oClockEn,
	output reg oCSN,
	output reg oRASN,
	output reg oCASN,
	output reg oWEn,
	output reg [1:0] oBank,
	output oDAMh,
	output oDAMl,
	output reg [11:0] oRamMemAddr,
	inout [15:0] ioRamData,

  // Input to UART
  input iRx,
  // Output to UART
  output reg oTx
  );

endmodule // mem_mgr
