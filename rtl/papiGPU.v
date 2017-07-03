`timescale 1ns / 1ps

`include "./pipeline/graphics_pipeline/graphics_pipeline.v"
`include "./mem_mgr/mem_mgr.v"
`include "./vga/vga.v"

module papiGPU (
  input iClock,
  input iReset,

  // Outputs to SRAM device
  output oClock,
  output reg oClockEn,
  output reg oCSN,
  output reg oRASN,
  output reg oCASN,
  output reg oWEn,
  output reg [1:0] oBank,
  output reg oDAMh,
  output reg oDAMl,
  inout wire [15:0] ioRamData,
  output reg [11:0] oRamMemAddr,
  output reg oRamMemAddr12 = 1'b0,

  // Input to UART
  input iRx,
  // Output to UART
  output reg oTx,

  output reg oRegToPinREAD, // TO VERIFY SRAM
	output reg oRegToPinWRITE, // TO VERIFY SRAM

  output reg LED_debug,

  // Outputs VGA
  output reg [2:0] oVGARed,
  output reg [2:0] oVGAGreen,
  output reg [1:0] oVGABlue,
  output reg 	     oVGAHorizontalSync,
  output reg 	     oVGAVerticalSync
);

  // Wires to SRAM Device
  wire wClock;
  assign oClock = wClock;
  wire wClockEn;
  wire wCSN;
  wire wRASN;
  wire wCASN;
  wire wWEn;
  wire [1:0] wBank;
  wire wDAMh;
  wire wDAMl;
  wire [11:0] wRamMemAddr;

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

  // Wire to UART Device
  wire wTx;

  // Wire of proyections
  wire [15:0] w_X;
  wire [15:0] w_Y;

  wire w_Exception;

  wire wRegToPinREAD; // TO VERIFY
	wire wRegToPinWRITE; // TO VERIFY

  wire wLED_debug;

  // Outputs VGA
  wire [2:0] wVGARed;
  wire [2:0] wVGAGreen;
  wire [1:0] wVGABlue;
  wire 	     wVGAHorizontalSync;
  wire 	     wVGAVerticalSync;

  ///////////////////
  // INSTANCE MODULES

  BUFG BUFG_inst (
			.O(clock_in), // 1-bit output: Clock buffer output
			.I(iClock)  // 1-bit input: Clock buffer input
	 );

  mem_mgr memory_manager(
    .iClock(clock_in),
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

    //Outputs to Memory device
    .oClock(wClock),
    .oClockEn(wClockEn),
    .oCSN(wCSN),
    .oRASN(wRASN),
    .oCASN(wCASN),
    .oWEn(wWEn),
    .oBank(wBank),
    .oDAMh(wDAMh),
    .oDAMl(wDAMl),
    .oRamMemAddr(wRamMemAddr),
    .ioRamData(ioRamData),

    .iRx(iRx),
    .oTx(wTx),

    .oRegToPinREAD(wRegToPinREAD), // TO VERIFY SRAM
  	.oRegToPinWRITE(wRegToPinWRITE), // TO VERIFY SRAM

    .LED_debug(wLED_debug)
  );

  graphicspipeline graphics_pipeline(
    .o_X(w_X),
    .o_Y(w_Y),
    .o_Exception(w_Exception),
    .i_CamVerX(wCamVerX),
    .i_CamVerY(wCamVerY),
    .i_CamVerZ(wCamVerZ),
    .i_CamDc(wCamDc),
    .i_CosRoll(wCosRoll),
    .i_CosPitch(wCosPitch),
    .i_CosYaw(wCosYaw),
    .i_SenRoll(wSenRoll),
    .i_SenPitch(wSenPitch),
    .i_SenYaw(wSenYaw),
    .i_ScaleX(wScaleX),
    .i_ScaleY(wScaleY),
    .i_ScaleZ(wScaleZ),
    .i_TranslX(wTranslX),
    .i_TranslY(wTranslY),
    .i_TranslZ(wTranslZ),
    .i_VertexX(wVertexX),
    .i_VertexY(wVertexY),
    .i_VertexZ(wVertexZ)
  );

  vga vga_inst (
    // Input general
    .iClock(clock_in),
    .iReset(iReset),

    // Input from Memory Manager
    .iEnable(wEnable),
    .iVertex(wInitVtx),
    .i_ieee754X(w_X),
    .i_ieee754Y(w_Y),

    // Outputs
    .oVGARed(wVGARed),
    .oVGAGreen(wVGAGreen),
    .oVGABlue(wVGABlue),
    .oVGAHorizontalSync(wVGAHorizontalSync),
    .oVGAVerticalSync(wVGAVerticalSync)
    );

  always @ ( * ) begin
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

    // Outputs VGA
    oVGARed = wVGARed;
    oVGAGreen = wVGAGreen;
    oVGABlue = wVGABlue;
    oVGAHorizontalSync = wVGAHorizontalSync;
    oVGAVerticalSync = wVGAVerticalSync;
  end

endmodule // papiGPU
