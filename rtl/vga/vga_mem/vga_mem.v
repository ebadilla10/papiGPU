`timescale 1ns / 1ps

module vga_mem # (
  parameter MEM_WIDTH_X = 120,
  parameter MEM_WIDTH_Y = 120
  )
  (
  // Inputs from Memory Manager
  input iEnable,
  input iVertex,

  // Inputs from INTEGER projections
  input iValid,
  input [6:0] iXm,
  input [6:0] iYm,

  // Inputs from VGA controller
  input [6:0] iVideoMemX,
  input [6:0] iVideoMemY,

  // Outputs to VGA Colors
  output reg [2:0] oVGARed,
  output reg [2:0] oVGAGreen,
  output reg [1:0] oVGABlue
  );

  parameter MEM_ADDR_BITS = 14;

  parameter TOTAL_MEM_WIDTH = MEM_WIDTH_X*MEM_WIDTH_Y;
  reg MemVideo [TOTAL_MEM_WIDTH-1: 0];

  reg [MEM_ADDR_BITS-1:0] i = 14'h0000;

  wire [MEM_ADDR_BITS-1:0] address;
  assign address = (14'd120 * iYm) + iXm;

  wire [MEM_ADDR_BITS-1:0] read_address;
  assign read_address = (14'd120 * iVideoMemY) + iVideoMemX;

/**
  always @ (posedge  iEnable) begin
    for (i = 0; i < TOTAL_MEM_WIDTH; i = i +1 ) begin
      MemVideo[i] = 1'b0;
    end

  end */

  always @ (posedge iVertex) begin
    if (iValid) begin
      MemVideo[address] = 1'b1;
    end
  end

  always @ ( * ) begin
    if(MemVideo[read_address]) begin
      // White Pixel
      oVGARed <= 3'b111;
      oVGAGreen <= 3'b111;
      oVGABlue <= 2'b11;
    end else begin
      // Black Pixel
      oVGARed <= 3'b000;
      oVGAGreen <= 3'b000;
      oVGABlue <= 2'b00;
    end

  end


endmodule
