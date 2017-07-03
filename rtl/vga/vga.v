`timescale 1ns / 1ps

`include "./vga_ctrl/vga_ctrl.v"
`include "./vga_mem/vga_mem.v"
`include "./vga_pixels/vga_pixels.v"

module vga (
  // Input general
  input wire 		     iClock,
  input wire 		     iReset,

  // Input from Memory Manager
  input iEnable,
  input iVertex,
  input  wire [15:0]	i_ieee754X,
  input  wire [15:0]	i_ieee754Y,

  // Outputs
  output wire [2:0] oVGARed,
  output wire [2:0] oVGAGreen,
  output wire [1:0] oVGABlue,
  output wire 	     oVGAHorizontalSync,
  output wire 	     oVGAVerticalSync
  );

  wire [6:0] wVideoMemX;
  wire [6:0] wVideoMemY;

  // Instantiation
  // -------------

  vga_ctrl vga_ctrl_inst
     (
      .iClock(iClock),
      .iReset(iReset),
      .oVideoMemCol(wVideoMemX),
      .oVideoMemRow(wVideoMemY),
      .oVGAHorizontalSync(oVGAHorizontalSync),
      .oVGAVerticalSync(oVGAVerticalSync)
      );

  wire [6:0] wPixelX;
  wire [6:0] wPixelY;
  wire wValid;

  vga_mem vga_mem_inst
    (
    // Inputs from Memory Manager
    .iEnable(iEnable),
    .iVertex(iVertex),
    // Inputs from INTEGER projections
    .iXm(wPixelX),
    .iYm(wPixelY),
    .iValid(wValid),
    // Inputs from VGA controller
    .iVideoMemX(wVideoMemX),
    .iVideoMemY(wVideoMemY),
    // Outputs to VGA Colors
    .oVGARed(oVGARed),
    .oVGAGreen(oVGAGreen),
    .oVGABlue(oVGABlue)
    );

    vga_pixels vga_pixels
    (
    .o_PixelesX(wPixelX),
    .o_PixelesY(wPixelY),
    .i_ieee754X(i_ieee754X),
    .i_ieee754Y(i_ieee754Y),
    .o_Valid(wValid)
    );

endmodule
