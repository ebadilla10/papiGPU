`timescale 1ns / 1ps

`include "./mem_ctrl/mem_ctrl.v"
`include "./sram/sram.v"
`include "./uart/uart.v"

module mem_mgr (
  input iClock,
  input iReset,

  // Outputs to Graphics Pipeline
  output reg        oEnable,
  output reg        oInitObj,
  output reg        oInitVtx,
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
  output reg oClock,
  output reg oClockEn,
  output reg oCSN,
  output reg oRASN,
  output reg oCASN,
  output reg oWEn,
  output reg [1:0] oBank,
  output reg oDAMh,
  output reg oDAMl,
  output reg [11:0] oRamMemAddr,
  inout [15:0] ioRamData,

  // Input to UART
  input iRx,
  // Output to UART
  output reg oTx,

  output reg oRegToPinREAD, // TO VERIFY
	output reg oRegToPinWRITE, // TO VERIFY

  output reg LED_debug
);

  // Wires between UART-MEM_CTRL
  wire [7:0] wRxByte, wTxByte;
  wire wRxReady, wRxError, wTxSent, wTxReady;

  // Wires between SRAM-MEM_CTRL
  wire [15:0] wData;
  wire wValidRead, wValidRequest, wWrite;
  wire [21:0] wAddress;

  // Wire to UART Device
  wire wTx;

  // Wires to SRAM Device
  wire wSRAMClock;
  wire wClockEn;
  wire wCSN;
  wire wRASN;
  wire wCASN;
  wire wWEn;
  wire [1:0] wBank;
  wire wDAMh;
  wire wDAMl;
  wire [11:0] wRamMemAddr;
  wire [15:0] wRamData;
  assign ioRamData = wRamData;

  // Wires for outputs
  wire wEnable;
  wire wInitObj;
  wire wInitVtx;
  wire [15:0] wCamVerX;
  wire [15:0] wCamVerY;
  wire [15:0] wCamVerZ;
  wire [15:0] wCamDc;
  wire [15:0] wCosRoll;
  wire [15:0] wCosPitch;
  wire [15:0] wCosYaw;
  wire [15:0] wSenRoll;
  wire [15:0] wSenPitch;
  wire [15:0] wSenYaw;
  wire [15:0] wScaleX;
  wire [15:0] wScaleY;
  wire [15:0] wScaleZ;
  wire [15:0] wTranslX;
  wire [15:0] wTranslY;
  wire [15:0] wTranslZ;
  wire [15:0] wVertexX;
  wire [15:0] wVertexY;
  wire [15:0] wVertexZ;

  wire wRegToPinREAD; // TO VERIFY
	wire wRegToPinWRITE; // TO VERIFY

  wire wLED_debug;

  ///////////////////
  // INSTANCE MODULES

  mem_ctrl memory_controller(
    .iClock(iClock),
    .iReset(iReset),

    .oEnable(wEnable),
    .oInitObj(wInitObj),
    .oInitVtx(wInitVtx),
    .oCamVerX(wCamVerX),
    .oCamVerY(wCamVerY),
    .oCamVerZ(wCamVerZ),
    .oCamDc(wCamDc),
    .oCosRoll(wCosRoll),
    .oCosPitch(wCosPitch),
    .oCosYaw(wCosYaw),
    .oSenRoll(wSenRoll),
    .oSenPitch(wSenPitch),
    .oSenYaw(wSenYaw),
    .oScaleX(wScaleX),
    .oScaleY(wScaleY),
    .oScaleZ(wScaleZ),
    .oTranslX(wTranslX),
    .oTranslY(wTranslY),
    .oTranslZ(wTranslZ),
    .oVertexX(wVertexX),
    .oVertexY(wVertexY),
    .oVertexZ(wVertexZ),

    .ioData(wData),
    .iValidRead(wValidRead),
    .oAddress(wAddress),
    .oValidRequest(wValidRequest),
    .oWrite(wWrite),

    .iRxByte(wRxByte),
    .iRxReady(wRxReady),
    .iRxError(wRxError),
    .iTxSent(wTxSent),

    .oTxByte(wTxByte),
    .oTxReady(wTxReady),

    .LED_debug(wLED_debug)
  );

  sram_ctrl sram_controller(
    .iClock(iClock),
    .iReset(iReset),

    //Inputs and outputs to controller from using module
    .iAddress(wAddress),
    .ioData(wData),
    .iValidRequest(wValidRequest),
    .iWrite(wWrite),
    .oValidRead(wValidRead),

    //Outputs to Memory device
    .oClock(wSRAMClock),
    .oClockEn(wClockEn),
    .oCSN(wCSN),
    .oRASN(wRASN),
    .oCASN(wCASN),
    .oWEn(wWEn),
    .oBank(wBank),
    .oDAMh(wDAMh),
    .oDAMl(wDAMl),
    .oRamMemAddr(wRamMemAddr),
    .ioRamData(wRamData),

    .oRegToPinREAD(wRegToPinREAD), // TO VERIFY SRAM
  	.oRegToPinWRITE(wRegToPinWRITE) // TO VERIFY SRAM
  );

  uart_ctrl uart_controller(
    .iClock(iClock),
    .iReset(iReset),

    .iRx(iRx),
    .oTxByte(wTxByte),
    .iTxReady(wTxReady),

    .oRxByte(wRxByte),
    .oRxReady(wRxReady),
    .oRxError(wRxError),
    .oTxSent(wTxSent),
    .oTx(wTx)
  );

  always @ ( * ) begin
    oEnable = wEnable;
    oInitObj = wInitObj;
    oInitVtx = wInitVtx;
    oCamVerX = wCamVerX;
    oCamVerY = wCamVerY;
    oCamVerZ = wCamVerZ;
    oCamDc = wCamDc;
    oCosRoll = wCosRoll;
    oCosPitch = wCosPitch;
    oCosYaw = wCosYaw;
    oSenRoll = wSenRoll;
    oSenPitch = wSenPitch;
    oSenYaw = wSenYaw;
    oScaleX = wScaleX;
    oScaleY = wScaleY;
    oScaleZ = wScaleZ;
    oTranslX = wTranslX;
    oTranslY = wTranslY;
    oTranslZ = wTranslZ;
    oVertexX = wVertexX;
    oVertexY = wVertexY;
    oVertexZ = wVertexZ;

    oClock = wSRAMClock;
    oClockEn = wClockEn;
    oCSN = wCSN;
    oRASN = wRASN;
    oCASN = wCASN;
    oWEn = wWEn;
    oBank = wBank;
    oDAMh = wDAMh;
    oDAMl = wDAMl;
    oRamMemAddr = wRamMemAddr;

    oTx = wTx;

    oRegToPinREAD = wRegToPinREAD; // TO VERIFY SRAM
  	oRegToPinWRITE = wRegToPinWRITE; // TO VERIFY SRAM

    LED_debug = wLED_debug;

  end

endmodule // mem_mgr
