`include "../../../rtl/mem_mgr/mem_ctrl/mem_ctrl.v"

`timescale 1ns / 1ps

module mem_ctrl_tb;

reg clk = 0;

reg rValidReadFlag = 1'b0;

// Inputs from UART
reg [7:0] iRxByte;
reg       iRxReady;
reg       iRxError;
reg       iTxSent;

// Inputs from SRAN
wire [15:0] ioData;
wire [21:0] oAddress;
wire        oValidRequest; // REQ
wire        oWrite;
reg         iValidRead;
reg [15:0]  Data = 16'h0000;

assign ioData = (!oWrite) ? Data : 16'hZZZZ;

parameter PERIOD = 31.25; //31.25ns = 32MHz
always begin
  clk = 1'b0;
  #(PERIOD/2) clk = 1'b1;
  #(PERIOD/2);
end

parameter CICLES_PER_BIT = 32000000/921600;

// Instantiate the Memory controller
mem_ctrl mem(
  .iClock(clk),
  .iRxByte(iRxByte),
  .iRxReady(iRxReady),
  .iRxError(iRxError),
  .iTxSent(iTxSent),

  .ioData(ioData),
  .oAddress(oAddress),
  .oValidRequest(oValidRequest),
  .oWrite(oWrite),
  .iValidRead(iValidRead)
);

// Initial the tested
initial begin

  $dumpfile("mem_ctrl.vcd");
  $dumpvars(0, mem_ctrl_tb);

  #(2*PERIOD);

  // INITIALIZING THE GPU
  // --------------------

  //---- 0xAAAA
  iRxByte = 8'hAA;
  iRxReady = 1'b1;
  iRxError = 1'b0;
  #(PERIOD);
  iRxReady = 1'b0;

  #(CICLES_PER_BIT * PERIOD * 10);

  iRxByte = 8'hAA;
  iRxReady = 1'b1;
  iRxError = 1'b0;
  #(PERIOD);
  iRxReady = 1'b0;

  // Sending answer
  #(CICLES_PER_BIT * PERIOD * 10);
  iTxSent = 1'b1;
  #(PERIOD);
  iTxSent = 1'b0;

  #(CICLES_PER_BIT * PERIOD * 10);

  //---- 0x0000
  iTxSent = 1'b1;
  #(PERIOD);
  iTxSent = 1'b0;

  iRxByte = 8'h00;
  iRxReady = 1'b1;
  iRxError = 1'b0;
  #(PERIOD);
  iRxReady = 1'b0;

  #(CICLES_PER_BIT * PERIOD * 10);

  iRxByte = 8'h00;
  iRxReady = 1'b1;
  iRxError = 1'b0;
  #(PERIOD);
  iRxReady = 1'b0;

  #(CICLES_PER_BIT * PERIOD * 10);

  //---- 0xCCCC

  iRxByte = 8'hCC;
  iRxReady = 1'b1;
  iRxError = 1'b0;
  #(PERIOD);
  iRxReady = 1'b0;

  #(CICLES_PER_BIT * PERIOD * 10);

  iRxByte = 8'hCC;
  iRxReady = 1'b1;
  iRxError = 1'b0;
  #(PERIOD);
  iRxReady = 1'b0;

  #(CICLES_PER_BIT * PERIOD * 10);

  //---- 0x0000

  iRxByte = 8'h00;
  iRxReady = 1'b1;
  iRxError = 1'b0;
  #(PERIOD);
  iRxReady = 1'b0;

  #(CICLES_PER_BIT * PERIOD * 10);

  iRxByte = 8'h00;
  iRxReady = 1'b1;
  iRxError = 1'b0;
  #(PERIOD);
  iRxReady = 1'b0;

  #(CICLES_PER_BIT * PERIOD * 10);

  //---- 0xFFFF

  iRxByte = 8'hFF;
  iRxReady = 1'b1;
  iRxError = 1'b0;
  #(PERIOD);
  iRxReady = 1'b0;

  #(CICLES_PER_BIT * PERIOD * 10);

  iRxByte = 8'hFF;
  iRxReady = 1'b1;
  iRxError = 1'b0;
  #(PERIOD);
  iRxReady = 1'b0;

  #(CICLES_PER_BIT * PERIOD * 10);

  // Sending answer
  iTxSent = 1'b1;
  #(PERIOD);
  iTxSent = 1'b0;

  #(CICLES_PER_BIT * PERIOD * 10);

  iTxSent = 1'b1;
  #(PERIOD);
  iTxSent = 1'b0;

  #(CICLES_PER_BIT * PERIOD * 10);

  // CONFIGURE CAMERA
  // ----------------

  //---- 0xBBBB
  iRxByte = 8'hBB;
  iRxReady = 1'b1;
  iRxError = 1'b0;
  #(PERIOD);
  iRxReady = 1'b0;

  #(CICLES_PER_BIT * PERIOD * 10);

  iRxByte = 8'hBB;
  iRxReady = 1'b1;
  iRxError = 1'b0;
  #(PERIOD);
  iRxReady = 1'b0;

  // Sending answer
  #(CICLES_PER_BIT * PERIOD * 10);
  iTxSent = 1'b1;
  #(PERIOD);
  iTxSent = 1'b0;

  #(CICLES_PER_BIT * PERIOD * 10);

  //---- 0x0002
  iTxSent = 1'b1;
  #(PERIOD);
  iTxSent = 1'b0;

  iRxByte = 8'h00;
  iRxReady = 1'b1;
  iRxError = 1'b0;
  #(PERIOD);
  iRxReady = 1'b0;

  #(CICLES_PER_BIT * PERIOD * 10);

  iRxByte = 8'h02;
  iRxReady = 1'b1;
  iRxError = 1'b0;
  #(PERIOD);
  iRxReady = 1'b0;

  #(CICLES_PER_BIT * PERIOD * 10);

  //---- 0xBBBB

  iRxByte = 8'hBB;
  iRxReady = 1'b1;
  iRxError = 1'b0;
  #(PERIOD);
  iRxReady = 1'b0;

  #(CICLES_PER_BIT * PERIOD * 10);

  iRxByte = 8'hBB;
  iRxReady = 1'b1;
  iRxError = 1'b0;
  #(PERIOD);
  iRxReady = 1'b0;

  #(CICLES_PER_BIT * PERIOD * 10);

  //---- 0x(Vx) = 0x1234

  iRxByte = 8'h12;
  iRxReady = 1'b1;
  iRxError = 1'b0;
  #(PERIOD);
  iRxReady = 1'b0;

  #(CICLES_PER_BIT * PERIOD * 10);

  iRxByte = 8'h34;
  iRxReady = 1'b1;
  iRxError = 1'b0;
  #(PERIOD);
  iRxReady = 1'b0;

  #(CICLES_PER_BIT * PERIOD * 10);

  //---- 0x(Vy) = 0x2345

  iRxByte = 8'h23;
  iRxReady = 1'b1;
  iRxError = 1'b0;
  #(PERIOD);
  iRxReady = 1'b0;

  #(CICLES_PER_BIT * PERIOD * 10);

  iRxByte = 8'h45;
  iRxReady = 1'b1;
  iRxError = 1'b0;
  #(PERIOD);
  iRxReady = 1'b0;

  #(CICLES_PER_BIT * PERIOD * 10);

  //---- 0x(Vz) = 0x3456

  iRxByte = 8'h34;
  iRxReady = 1'b1;
  iRxError = 1'b0;
  #(PERIOD);
  iRxReady = 1'b0;

  #(CICLES_PER_BIT * PERIOD * 10);

  iRxByte = 8'h56;
  iRxReady = 1'b1;
  iRxError = 1'b0;
  #(PERIOD);
  iRxReady = 1'b0;

  #(CICLES_PER_BIT * PERIOD * 10);

  //---- 0x(Dc) = 0x4567

  iRxByte = 8'h45;
  iRxReady = 1'b1;
  iRxError = 1'b0;
  #(PERIOD);
  iRxReady = 1'b0;

  #(CICLES_PER_BIT * PERIOD * 10);

  iRxByte = 8'h67;
  iRxReady = 1'b1;
  iRxError = 1'b0;
  #(PERIOD);
  iRxReady = 1'b0;

  #(CICLES_PER_BIT * PERIOD * 10);

  //---- 0xFFFF

  iRxByte = 8'hFF;
  iRxReady = 1'b1;
  iRxError = 1'b0;
  #(PERIOD);
  iRxReady = 1'b0;

  #(CICLES_PER_BIT * PERIOD * 10);

  iRxByte = 8'hFF;
  iRxReady = 1'b1;
  iRxError = 1'b0;
  #(PERIOD);
  iRxReady = 1'b0;

  #(CICLES_PER_BIT * PERIOD * 10);

  // Sending answer
  #(CICLES_PER_BIT * PERIOD * 10);
  iTxSent = 1'b1;
  #(PERIOD);
  iTxSent = 1'b0;

  #(CICLES_PER_BIT * PERIOD * 10);

  iTxSent = 1'b1;
  #(PERIOD);
  iTxSent = 1'b0;

  #(CICLES_PER_BIT * PERIOD * 10);

  // CONFIGURE OBJECT
  // ----------------

  //---- 0xEEEE
  iRxByte = 8'hEE;
  iRxReady = 1'b1;
  iRxError = 1'b0;
  #(PERIOD);
  iRxReady = 1'b0;

  #(CICLES_PER_BIT * PERIOD * 10);

  iRxByte = 8'hEE;
  iRxReady = 1'b1;
  iRxError = 1'b0;
  #(PERIOD);
  iRxReady = 1'b0;

  // Sending answer
  #(CICLES_PER_BIT * PERIOD * 10);
  iTxSent = 1'b1;
  #(PERIOD);
  iTxSent = 1'b0;

  #(CICLES_PER_BIT * PERIOD * 10);

  //---- 0x0007
  iTxSent = 1'b1;
  #(PERIOD);
  iTxSent = 1'b0;

  iRxByte = 8'h00;
  iRxReady = 1'b1;
  iRxError = 1'b0;
  #(PERIOD);
  iRxReady = 1'b0;

  #(CICLES_PER_BIT * PERIOD * 10);

  iRxByte = 8'h07;
  iRxReady = 1'b1;
  iRxError = 1'b0;
  #(PERIOD);
  iRxReady = 1'b0;

  #(CICLES_PER_BIT * PERIOD * 10);

  //---- 0xEEEE

  iRxByte = 8'hEE;
  iRxReady = 1'b1;
  iRxError = 1'b0;
  #(PERIOD);
  iRxReady = 1'b0;

  #(CICLES_PER_BIT * PERIOD * 10);

  iRxByte = 8'hEE;
  iRxReady = 1'b1;
  iRxError = 1'b0;
  #(PERIOD);
  iRxReady = 1'b0;

  #(CICLES_PER_BIT * PERIOD * 10);

  //---- 0x0000

  iRxByte = 8'h00;
  iRxReady = 1'b1;
  iRxError = 1'b0;
  #(PERIOD);
  iRxReady = 1'b0;

  #(CICLES_PER_BIT * PERIOD * 10);

  iRxByte = 8'h00;
  iRxReady = 1'b1;
  iRxError = 1'b0;
  #(PERIOD);
  iRxReady = 1'b0;

  #(CICLES_PER_BIT * PERIOD * 10);

  //---- 0x(Cos(yaw)) = 0x1234

  iRxByte = 8'h12;
  iRxReady = 1'b1;
  iRxError = 1'b0;
  #(PERIOD);
  iRxReady = 1'b0;

  #(CICLES_PER_BIT * PERIOD * 10);

  iRxByte = 8'h34;
  iRxReady = 1'b1;
  iRxError = 1'b0;
  #(PERIOD);
  iRxReady = 1'b0;

  #(CICLES_PER_BIT * PERIOD * 10);

  //---- 0x(Cos(pitch)) = 0x2345

  iRxByte = 8'h23;
  iRxReady = 1'b1;
  iRxError = 1'b0;
  #(PERIOD);
  iRxReady = 1'b0;

  #(CICLES_PER_BIT * PERIOD * 10);

  iRxByte = 8'h45;
  iRxReady = 1'b1;
  iRxError = 1'b0;
  #(PERIOD);
  iRxReady = 1'b0;

  #(CICLES_PER_BIT * PERIOD * 10);

  //---- 0x(Cos(roll)) = 0x3456

  iRxByte = 8'h34;
  iRxReady = 1'b1;
  iRxError = 1'b0;
  #(PERIOD);
  iRxReady = 1'b0;

  #(CICLES_PER_BIT * PERIOD * 10);

  iRxByte = 8'h56;
  iRxReady = 1'b1;
  iRxError = 1'b0;
  #(PERIOD);
  iRxReady = 1'b0;

  #(CICLES_PER_BIT * PERIOD * 10);

  //---- 0x(Sen(yaw)) = 0x4567

  iRxByte = 8'h45;
  iRxReady = 1'b1;
  iRxError = 1'b0;
  #(PERIOD);
  iRxReady = 1'b0;

  #(CICLES_PER_BIT * PERIOD * 10);

  iRxByte = 8'h67;
  iRxReady = 1'b1;
  iRxError = 1'b0;
  #(PERIOD);
  iRxReady = 1'b0;

  #(CICLES_PER_BIT * PERIOD * 10);

  //---- 0x(Sen(pitch)) = 0x5678

  iRxByte = 8'h54;
  iRxReady = 1'b1;
  iRxError = 1'b0;
  #(PERIOD);
  iRxReady = 1'b0;

  #(CICLES_PER_BIT * PERIOD * 10);

  iRxByte = 8'h78;
  iRxReady = 1'b1;
  iRxError = 1'b0;
  #(PERIOD);
  iRxReady = 1'b0;

  #(CICLES_PER_BIT * PERIOD * 10);

  //---- 0x(Sen(roll)) = 0x6789

  iRxByte = 8'h67;
  iRxReady = 1'b1;
  iRxError = 1'b0;
  #(PERIOD);
  iRxReady = 1'b0;

  #(CICLES_PER_BIT * PERIOD * 10);

  iRxByte = 8'h89;
  iRxReady = 1'b1;
  iRxError = 1'b0;
  #(PERIOD);
  iRxReady = 1'b0;

  #(CICLES_PER_BIT * PERIOD * 10);

  //---- 0x(ScaleX) = 0x789A

  iRxByte = 8'h78;
  iRxReady = 1'b1;
  iRxError = 1'b0;
  #(PERIOD);
  iRxReady = 1'b0;

  #(CICLES_PER_BIT * PERIOD * 10);

  iRxByte = 8'h9A;
  iRxReady = 1'b1;
  iRxError = 1'b0;
  #(PERIOD);
  iRxReady = 1'b0;

  #(CICLES_PER_BIT * PERIOD * 10);

  //---- 0x(ScaleY) = 0x89AB

  iRxByte = 8'h89;
  iRxReady = 1'b1;
  iRxError = 1'b0;
  #(PERIOD);
  iRxReady = 1'b0;

  #(CICLES_PER_BIT * PERIOD * 10);

  iRxByte = 8'hAB;
  iRxReady = 1'b1;
  iRxError = 1'b0;
  #(PERIOD);
  iRxReady = 1'b0;

  #(CICLES_PER_BIT * PERIOD * 10);

  //---- 0x(ScaleZ) = 0x9ABC

  iRxByte = 8'h9A;
  iRxReady = 1'b1;
  iRxError = 1'b0;
  #(PERIOD);
  iRxReady = 1'b0;

  #(CICLES_PER_BIT * PERIOD * 10);

  iRxByte = 8'hBC;
  iRxReady = 1'b1;
  iRxError = 1'b0;
  #(PERIOD);
  iRxReady = 1'b0;

  #(CICLES_PER_BIT * PERIOD * 10);

  //---- 0x(TranslX) = 0xABCD

  iRxByte = 8'hAB;
  iRxReady = 1'b1;
  iRxError = 1'b0;
  #(PERIOD);
  iRxReady = 1'b0;

  #(CICLES_PER_BIT * PERIOD * 10);

  iRxByte = 8'hCD;
  iRxReady = 1'b1;
  iRxError = 1'b0;
  #(PERIOD);
  iRxReady = 1'b0;

  #(CICLES_PER_BIT * PERIOD * 10);

  //---- 0x(TranslY) = 0xBCDE

  iRxByte = 8'hBC;
  iRxReady = 1'b1;
  iRxError = 1'b0;
  #(PERIOD);
  iRxReady = 1'b0;

  #(CICLES_PER_BIT * PERIOD * 10);

  iRxByte = 8'hDE;
  iRxReady = 1'b1;
  iRxError = 1'b0;
  #(PERIOD);
  iRxReady = 1'b0;

  #(CICLES_PER_BIT * PERIOD * 10);

  //---- 0x(TranslZ) = 0xCDEF

  iRxByte = 8'hCD;
  iRxReady = 1'b1;
  iRxError = 1'b0;
  #(PERIOD);
  iRxReady = 1'b0;

  #(CICLES_PER_BIT * PERIOD * 10);

  iRxByte = 8'hEF;
  iRxReady = 1'b1;
  iRxError = 1'b0;
  #(PERIOD);
  iRxReady = 1'b0;

  #(CICLES_PER_BIT * PERIOD * 10);

  //---- 0xFFFF

  iRxByte = 8'hFF;
  iRxReady = 1'b1;
  iRxError = 1'b0;
  #(PERIOD);
  iRxReady = 1'b0;

  #(CICLES_PER_BIT * PERIOD * 10);

  iRxByte = 8'hFF;
  iRxReady = 1'b1;
  iRxError = 1'b0;
  #(PERIOD);
  iRxReady = 1'b0;

  #(CICLES_PER_BIT * PERIOD * 10);

  // Sending answer
  #(CICLES_PER_BIT * PERIOD * 10);
  iTxSent = 1'b1;
  #(PERIOD);
  iTxSent = 1'b0;

  #(CICLES_PER_BIT * PERIOD * 10);

  iTxSent = 1'b1;
  #(PERIOD);
  iTxSent = 1'b0;

  #(CICLES_PER_BIT * PERIOD * 10);

  // CONFIGURE VERTICES
  // ------------------

  //---- 0x9999
  iRxByte = 8'h99;
  iRxReady = 1'b1;
  iRxError = 1'b0;
  #(PERIOD);
  iRxReady = 1'b0;

  #(CICLES_PER_BIT * PERIOD * 10);

  iRxByte = 8'h99;
  iRxReady = 1'b1;
  iRxError = 1'b0;
  #(PERIOD);
  iRxReady = 1'b0;

  // Sending answer
  #(CICLES_PER_BIT * PERIOD * 10);
  iTxSent = 1'b1;
  #(PERIOD);
  iTxSent = 1'b0;

  #(CICLES_PER_BIT * PERIOD * 10);

  //---- Number of vertices = 0x0002
  iTxSent = 1'b1;
  #(PERIOD);
  iTxSent = 1'b0;

  iRxByte = 8'h00;
  iRxReady = 1'b1;
  iRxError = 1'b0;
  #(PERIOD);
  iRxReady = 1'b0;

  #(CICLES_PER_BIT * PERIOD * 10);

  iRxByte = 8'h02;
  iRxReady = 1'b1;
  iRxError = 1'b0;
  #(PERIOD);
  iRxReady = 1'b0;

  #(CICLES_PER_BIT * PERIOD * 10);

  //---- 0x0015

  iRxByte = 8'h00;
  iRxReady = 1'b1;
  iRxError = 1'b0;
  #(PERIOD);
  iRxReady = 1'b0;

  #(CICLES_PER_BIT * PERIOD * 10);

  iRxByte = 8'h15;
  iRxReady = 1'b1;
  iRxError = 1'b0;
  #(PERIOD);
  iRxReady = 1'b0;

  #(CICLES_PER_BIT * PERIOD * 10);

  //---- 0x9999

  iRxByte = 8'h99;
  iRxReady = 1'b1;
  iRxError = 1'b0;
  #(PERIOD);
  iRxReady = 1'b0;

  #(CICLES_PER_BIT * PERIOD * 10);

  iRxByte = 8'h99;
  iRxReady = 1'b1;
  iRxError = 1'b0;
  #(PERIOD);
  iRxReady = 1'b0;

  #(CICLES_PER_BIT * PERIOD * 10);

  //---- 0x(X1) = 0x1234

  iRxByte = 8'h12;
  iRxReady = 1'b1;
  iRxError = 1'b0;
  #(PERIOD);
  iRxReady = 1'b0;

  #(CICLES_PER_BIT * PERIOD * 10);

  iRxByte = 8'h34;
  iRxReady = 1'b1;
  iRxError = 1'b0;
  #(PERIOD);
  iRxReady = 1'b0;

  #(CICLES_PER_BIT * PERIOD * 10);

  //---- 0x(Y1) = 0x2345

  iRxByte = 8'h23;
  iRxReady = 1'b1;
  iRxError = 1'b0;
  #(PERIOD);
  iRxReady = 1'b0;

  #(CICLES_PER_BIT * PERIOD * 10);

  iRxByte = 8'h45;
  iRxReady = 1'b1;
  iRxError = 1'b0;
  #(PERIOD);
  iRxReady = 1'b0;

  #(CICLES_PER_BIT * PERIOD * 10);

  //---- 0x(Z1) = 0x3456

  iRxByte = 8'h34;
  iRxReady = 1'b1;
  iRxError = 1'b0;
  #(PERIOD);
  iRxReady = 1'b0;

  #(CICLES_PER_BIT * PERIOD * 10);

  iRxByte = 8'h56;
  iRxReady = 1'b1;
  iRxError = 1'b0;
  #(PERIOD);
  iRxReady = 1'b0;

  #(CICLES_PER_BIT * PERIOD * 10);

  //---- 0x(X2) = 0x4567

  iRxByte = 8'h45;
  iRxReady = 1'b1;
  iRxError = 1'b0;
  #(PERIOD);
  iRxReady = 1'b0;

  #(CICLES_PER_BIT * PERIOD * 10);

  iRxByte = 8'h67;
  iRxReady = 1'b1;
  iRxError = 1'b0;
  #(PERIOD);
  iRxReady = 1'b0;

  #(CICLES_PER_BIT * PERIOD * 10);

  //---- 0x(Y2) = 0x5678

  iRxByte = 8'h56;
  iRxReady = 1'b1;
  iRxError = 1'b0;
  #(PERIOD);
  iRxReady = 1'b0;

  #(CICLES_PER_BIT * PERIOD * 10);

  iRxByte = 8'h78;
  iRxReady = 1'b1;
  iRxError = 1'b0;
  #(PERIOD);
  iRxReady = 1'b0;

  #(CICLES_PER_BIT * PERIOD * 10);

  //---- 0x(Z2) = 0x6789

  iRxByte = 8'h67;
  iRxReady = 1'b1;
  iRxError = 1'b0;
  #(PERIOD);
  iRxReady = 1'b0;

  #(CICLES_PER_BIT * PERIOD * 10);

  iRxByte = 8'h89;
  iRxReady = 1'b1;
  iRxError = 1'b0;
  #(PERIOD);
  iRxReady = 1'b0;

  #(CICLES_PER_BIT * PERIOD * 10);

  //---- 0xFFFF

  iRxByte = 8'hFF;
  iRxReady = 1'b1;
  iRxError = 1'b0;
  #(PERIOD);
  iRxReady = 1'b0;

  #(CICLES_PER_BIT * PERIOD * 10);

  iRxByte = 8'hFF;
  iRxReady = 1'b1;
  iRxError = 1'b0;
  #(PERIOD);
  iRxReady = 1'b0;

  // Sending answer
  #(CICLES_PER_BIT * PERIOD * 10);
  iTxSent = 1'b1;
  #(PERIOD);
  iTxSent = 1'b0;

  #(CICLES_PER_BIT * PERIOD * 10);

  iTxSent = 1'b1;
  #(PERIOD);
  iTxSent = 1'b0;

  #(CICLES_PER_BIT * PERIOD * 10);

  // CLOSE OBJECT
  // ------------

  //---- 0x8888
  iRxByte = 8'h88;
  iRxReady = 1'b1;
  iRxError = 1'b0;
  #(PERIOD);
  iRxReady = 1'b0;

  #(CICLES_PER_BIT * PERIOD * 10);

  iRxByte = 8'h88;
  iRxReady = 1'b1;
  iRxError = 1'b0;
  #(PERIOD);
  iRxReady = 1'b0;

  // Sending answer
  #(CICLES_PER_BIT * PERIOD * 10);
  iTxSent = 1'b1;
  #(PERIOD);
  iTxSent = 1'b0;

  #(CICLES_PER_BIT * PERIOD * 10);

  //---- 0X0008
  iTxSent = 1'b1;
  #(PERIOD);
  iTxSent = 1'b0;

  iRxByte = 8'h00;
  iRxReady = 1'b1;
  iRxError = 1'b0;
  #(PERIOD);
  iRxReady = 1'b0;

  #(CICLES_PER_BIT * PERIOD * 10);

  iRxByte = 8'h08;
  iRxReady = 1'b1;
  iRxError = 1'b0;
  #(PERIOD);
  iRxReady = 1'b0;

  #(CICLES_PER_BIT * PERIOD * 10);

  //---- 0x(Next Object Address) = 0x001C

  iRxByte = 8'h00;
  iRxReady = 1'b1;
  iRxError = 1'b0;
  #(PERIOD);
  iRxReady = 1'b0;

  #(CICLES_PER_BIT * PERIOD * 10);

  iRxByte = 8'h01;
  iRxReady = 1'b1;
  iRxError = 1'b0;
  #(PERIOD);
  iRxReady = 1'b0;

  #(CICLES_PER_BIT * PERIOD * 10);

  //---- 0xFFFF

  iRxByte = 8'hFF;
  iRxReady = 1'b1;
  iRxError = 1'b0;
  #(PERIOD);
  iRxReady = 1'b0;

  #(CICLES_PER_BIT * PERIOD * 10);

  iRxByte = 8'hFF;
  iRxReady = 1'b1;
  iRxError = 1'b0;
  #(PERIOD);
  iRxReady = 1'b0;

  // Sending answer
  #(CICLES_PER_BIT * PERIOD * 10);
  iTxSent = 1'b1;
  #(PERIOD);
  iTxSent = 1'b0;

  #(CICLES_PER_BIT * PERIOD * 10);

  iTxSent = 1'b1;
  #(PERIOD);
  iTxSent = 1'b0;

  #(CICLES_PER_BIT * PERIOD * 10);

  // CONFIGURE OBJECT CONFIGURATION MODIFY
  //---- 0xABCD
  iRxByte = 8'hAB;
  iRxReady = 1'b1;
  iRxError = 1'b0;
  #(PERIOD);
  iRxReady = 1'b0;

  #(CICLES_PER_BIT * PERIOD * 10);

  iRxByte = 8'hCD;
  iRxReady = 1'b1;
  iRxError = 1'b0;
  #(PERIOD);
  iRxReady = 1'b0;

  // Sending answer
  #(CICLES_PER_BIT * PERIOD * 10);
  iTxSent = 1'b1;
  #(PERIOD);
  iTxSent = 1'b0;

  #(CICLES_PER_BIT * PERIOD * 10);

  //---- 0x0009
  iTxSent = 1'b1;
  #(PERIOD);
  iTxSent = 1'b0;

  iRxByte = 8'h00;
  iRxReady = 1'b1;
  iRxError = 1'b0;
  #(PERIOD);
  iRxReady = 1'b0;

  #(CICLES_PER_BIT * PERIOD * 10);

  iRxByte = 8'h09;
  iRxReady = 1'b1;
  iRxError = 1'b0;
  #(PERIOD);
  iRxReady = 1'b0;

  #(CICLES_PER_BIT * PERIOD * 10);

  //---- 0x(Cos(yaw)) = 0x1111

  iRxByte = 8'h11;
  iRxReady = 1'b1;
  iRxError = 1'b0;
  #(PERIOD);
  iRxReady = 1'b0;

  #(CICLES_PER_BIT * PERIOD * 10);

  iRxByte = 8'h11;
  iRxReady = 1'b1;
  iRxError = 1'b0;
  #(PERIOD);
  iRxReady = 1'b0;

  #(CICLES_PER_BIT * PERIOD * 10);

  //---- 0x(Cos(pitch)) = 0x2222

  iRxByte = 8'h22;
  iRxReady = 1'b1;
  iRxError = 1'b0;
  #(PERIOD);
  iRxReady = 1'b0;

  #(CICLES_PER_BIT * PERIOD * 10);

  iRxByte = 8'h22;
  iRxReady = 1'b1;
  iRxError = 1'b0;
  #(PERIOD);
  iRxReady = 1'b0;

  #(CICLES_PER_BIT * PERIOD * 10);

  //---- 0x(Cos(roll)) = 0x3333

  iRxByte = 8'h33;
  iRxReady = 1'b1;
  iRxError = 1'b0;
  #(PERIOD);
  iRxReady = 1'b0;

  #(CICLES_PER_BIT * PERIOD * 10);

  iRxByte = 8'h33;
  iRxReady = 1'b1;
  iRxError = 1'b0;
  #(PERIOD);
  iRxReady = 1'b0;

  #(CICLES_PER_BIT * PERIOD * 10);

  //---- 0x(Sen(yaw)) = 0x4444

  iRxByte = 8'h44;
  iRxReady = 1'b1;
  iRxError = 1'b0;
  #(PERIOD);
  iRxReady = 1'b0;

  #(CICLES_PER_BIT * PERIOD * 10);

  iRxByte = 8'h44;
  iRxReady = 1'b1;
  iRxError = 1'b0;
  #(PERIOD);
  iRxReady = 1'b0;

  #(CICLES_PER_BIT * PERIOD * 10);

  //---- 0x(Sen(pitch)) = 0x5555

  iRxByte = 8'h55;
  iRxReady = 1'b1;
  iRxError = 1'b0;
  #(PERIOD);
  iRxReady = 1'b0;

  #(CICLES_PER_BIT * PERIOD * 10);

  iRxByte = 8'h55;
  iRxReady = 1'b1;
  iRxError = 1'b0;
  #(PERIOD);
  iRxReady = 1'b0;

  #(CICLES_PER_BIT * PERIOD * 10);

  //---- 0x(Sen(roll)) = 0x6666

  iRxByte = 8'h66;
  iRxReady = 1'b1;
  iRxError = 1'b0;
  #(PERIOD);
  iRxReady = 1'b0;

  #(CICLES_PER_BIT * PERIOD * 10);

  iRxByte = 8'h66;
  iRxReady = 1'b1;
  iRxError = 1'b0;
  #(PERIOD);
  iRxReady = 1'b0;

  #(CICLES_PER_BIT * PERIOD * 10);

  //---- 0x(ScaleX) = 0x7777

  iRxByte = 8'h77;
  iRxReady = 1'b1;
  iRxError = 1'b0;
  #(PERIOD);
  iRxReady = 1'b0;

  #(CICLES_PER_BIT * PERIOD * 10);

  iRxByte = 8'h77;
  iRxReady = 1'b1;
  iRxError = 1'b0;
  #(PERIOD);
  iRxReady = 1'b0;

  #(CICLES_PER_BIT * PERIOD * 10);

  //---- 0x(ScaleY) = 0x8888

  iRxByte = 8'h88;
  iRxReady = 1'b1;
  iRxError = 1'b0;
  #(PERIOD);
  iRxReady = 1'b0;

  #(CICLES_PER_BIT * PERIOD * 10);

  iRxByte = 8'h88;
  iRxReady = 1'b1;
  iRxError = 1'b0;
  #(PERIOD);
  iRxReady = 1'b0;

  #(CICLES_PER_BIT * PERIOD * 10);

  //---- 0x(ScaleZ) = 0x9999

  iRxByte = 8'h99;
  iRxReady = 1'b1;
  iRxError = 1'b0;
  #(PERIOD);
  iRxReady = 1'b0;

  #(CICLES_PER_BIT * PERIOD * 10);

  iRxByte = 8'h99;
  iRxReady = 1'b1;
  iRxError = 1'b0;
  #(PERIOD);
  iRxReady = 1'b0;

  #(CICLES_PER_BIT * PERIOD * 10);

  //---- 0x(TranslX) = 0xAAAA

  iRxByte = 8'hAA;
  iRxReady = 1'b1;
  iRxError = 1'b0;
  #(PERIOD);
  iRxReady = 1'b0;

  #(CICLES_PER_BIT * PERIOD * 10);

  iRxByte = 8'hAA;
  iRxReady = 1'b1;
  iRxError = 1'b0;
  #(PERIOD);
  iRxReady = 1'b0;

  #(CICLES_PER_BIT * PERIOD * 10);

  //---- 0x(TranslY) = 0xBBBB

  iRxByte = 8'hBB;
  iRxReady = 1'b1;
  iRxError = 1'b0;
  #(PERIOD);
  iRxReady = 1'b0;

  #(CICLES_PER_BIT * PERIOD * 10);

  iRxByte = 8'hBB;
  iRxReady = 1'b1;
  iRxError = 1'b0;
  #(PERIOD);
  iRxReady = 1'b0;

  #(CICLES_PER_BIT * PERIOD * 10);

  //---- 0x(TranslZ) = 0xCCCC

  iRxByte = 8'hCC;
  iRxReady = 1'b1;
  iRxError = 1'b0;
  #(PERIOD);
  iRxReady = 1'b0;

  #(CICLES_PER_BIT * PERIOD * 10);

  iRxByte = 8'hCC;
  iRxReady = 1'b1;
  iRxError = 1'b0;
  #(PERIOD);
  iRxReady = 1'b0;

  #(CICLES_PER_BIT * PERIOD * 10);

  //---- 0xFFFF

  iRxByte = 8'hFF;
  iRxReady = 1'b1;
  iRxError = 1'b0;
  #(PERIOD);
  iRxReady = 1'b0;

  #(CICLES_PER_BIT * PERIOD * 10);

  iRxByte = 8'hFF;
  iRxReady = 1'b1;
  iRxError = 1'b0;
  #(PERIOD);
  iRxReady = 1'b0;

  #(CICLES_PER_BIT * PERIOD * 10);

  // Sending answer
  #(CICLES_PER_BIT * PERIOD * 10);
  iTxSent = 1'b1;
  #(PERIOD);
  iTxSent = 1'b0;

  #(CICLES_PER_BIT * PERIOD * 10);

  iTxSent = 1'b1;
  #(PERIOD);
  iTxSent = 1'b0;

  #(CICLES_PER_BIT * PERIOD * 10);

  // CONFIGURE REFRESH
  // -----------------

  //---- 0x1234
  iRxByte = 8'h12;
  iRxReady = 1'b1;
  iRxError = 1'b0;
  #(PERIOD);
  iRxReady = 1'b0;

  #(CICLES_PER_BIT * PERIOD * 10);

  iRxByte = 8'h34;
  iRxReady = 1'b1;
  iRxError = 1'b0;
  #(PERIOD);
  iRxReady = 1'b0;

  // Sending answer
  #(CICLES_PER_BIT * PERIOD * 10);
  iTxSent = 1'b1;
  #(PERIOD);
  iTxSent = 1'b0;

  #(CICLES_PER_BIT * PERIOD * 10);

  //---- 0xAAAA
  iTxSent = 1'b1;
  #(PERIOD);
  iTxSent = 1'b0;

  iRxByte = 8'hAA;
  iRxReady = 1'b1;
  iRxError = 1'b0;
  #(PERIOD);
  iRxReady = 1'b0;

  #(CICLES_PER_BIT * PERIOD * 10);

  iRxByte = 8'hAA;
  iRxReady = 1'b1;
  iRxError = 1'b0;
  #(PERIOD);
  iRxReady = 1'b0;

  // WAIT FOR FINISH
  #(PERIOD * 350);

  $finish;
end

always @ ( posedge  oValidRequest) begin

  if (!oWrite) begin
    #(6 * PERIOD);

    case (oAddress)
      0: Data = 16'hCCCC;
      1: Data = 16'h0001;
      2: Data = 16'hBBBB;
      3: Data = 16'h1234;
      4: Data = 16'h2345;
      5: Data = 16'h3456;
      6: Data = 16'h4567;
      7: Data = 16'hEEEE;
      8: Data = 16'h001C;
      9: Data = 16'h1234;
      10: Data = 16'h2345;
      11: Data = 16'h3456;
      12: Data = 16'h4567;
      13: Data = 16'h5678;
      14: Data = 16'h6789;
      15: Data = 16'h789A;
      16: Data = 16'h89AB;
      17: Data = 16'h9ABC;
      18: Data = 16'hABCD;
      19: Data = 16'hBCDE;
      20: Data = 16'hCDEF;
      21: Data = 16'h9999;
      22: Data = 16'h1234;
      23: Data = 16'h2345;
      24: Data = 16'h3456;
      25: Data = 16'h4567;
      26: Data = 16'h5678;
      27: Data = 16'h6789;
      28: Data = 16'hFFFF;
      default: Data = 16'hFFFF;
    endcase

    iValidRead = 1'b1;

  end // !oWrite

end

always @ ( posedge clk ) begin
if (iValidRead) begin
  case (rValidReadFlag)

    1'b0: rValidReadFlag <= 1'b1;

    1'b1: begin
      iValidRead <= 1'b0;
      rValidReadFlag <= 1'b0;
    end // case DOWN

  endcase // rValidReqFlag
end
end

endmodule
