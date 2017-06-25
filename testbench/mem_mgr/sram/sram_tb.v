`include "../../../rtl/mem_mgr/sram/sram_hw.v"

`timescale 1ns / 1ps

module sram_tb ;

reg clk = 0;
reg rst = 0;

// Inputs from SRAN
reg [15:0] oData;
reg [21:0] oAddress;
reg        oValidRequest; // REQ
reg        oWrite;

reg [15:0] ioDataFromSRAM;

wire [15:0] Data;
assign Data = (oWrite) ? oData : 16'hZZZZ;

wire [15:0] DataFromSRAM;
assign DataFromSRAM = (!oWrite) ? ioDataFromSRAM : 16'hZZZZ;

wire cs;
wire ras;
wire cas;
wire we;

//////////////////
// Begin the Clock
parameter PERIOD = 31.25; //31.25ns = 32MHz
always begin
  clk = 1'b0;
  #(PERIOD/2) clk = 1'b1;
  #(PERIOD/2);
end

sram_ctrl sram(
  .iClock(clk),
  .iReset(rst),

  .ioData(Data),
  .iAddress(oAddress),
  .iValidRequest(oValidRequest),
  .iWrite(oWrite),

  .oCSN(cs),
  .oRASN(ras),
  .oCASN(cas),
  .oWEn(we),

  .ioRamData(DataFromSRAM)
);

// Initial the tested
initial begin

  $dumpfile("sram_tb.vcd");
  $dumpvars(0, sram_tb);

  oValidRequest = 1'b0;
  oWrite = 1'b0;

  #110000 // Wait for device init

  // JUST WRITE
  oWrite = 1'b1;

  oData = 16'hCCCC;
  oAddress = 22'h0C0000;
  oValidRequest = 1'b1;
  #(PERIOD);
  oValidRequest = 1'b0;
  #(9*PERIOD);

  oData = 16'h0000;
  oAddress = 22'h000001;
  oValidRequest = 1'b1;
  #(PERIOD);
  oValidRequest = 1'b0;
  #(9*PERIOD);

  oData = 16'hFFFF;
  oAddress = 22'h000002;
  oValidRequest = 1'b1;
  #(PERIOD);
  oValidRequest = 1'b0;
  #(9*PERIOD);

  oData = 16'hBBBB;
  oAddress = 22'h000002;
  oValidRequest = 1'b1;
  #(PERIOD);
  oValidRequest = 1'b0;
  #(9*PERIOD);

  oData = 16'h1234;
  oAddress = 22'h000003;
  oValidRequest = 1'b1;
  #(PERIOD);
  oValidRequest = 1'b0;
  #(9*PERIOD);

  oData = 16'h2345;
  oAddress = 22'h000004;
  oValidRequest = 1'b1;
  #(PERIOD);
  oValidRequest = 1'b0;
  #(9*PERIOD);

  oData = 16'h3456;
  oAddress = 22'h000005;
  oValidRequest = 1'b1;
  #(PERIOD);
  oValidRequest = 1'b0;
  #(9*PERIOD);

  oData = 16'h4567;
  oAddress = 22'h000006;
  oValidRequest = 1'b1;
  #(PERIOD);
  oValidRequest = 1'b0;
  #(9*PERIOD);

  oData = 16'hFFFF;
  oAddress = 22'h000007;
  oValidRequest = 1'b1;
  #(PERIOD);
  oValidRequest = 1'b0;
  #(9*PERIOD);

  oData = 16'hEEEE;
  oAddress = 22'h000007;
  oValidRequest = 1'b1;
  #(PERIOD);
  oValidRequest = 1'b0;
  #(9*PERIOD);

  oData = 16'h0000;
  oAddress = 22'h000008;
  oValidRequest = 1'b1;
  #(PERIOD);
  oValidRequest = 1'b0;
  #(9*PERIOD);

  oData = 16'h1234;
  oAddress = 22'h000009;
  oValidRequest = 1'b1;
  #(PERIOD);
  oValidRequest = 1'b0;
  #(9*PERIOD);

  oData = 16'h2345;
  oAddress = 22'h00000A;
  oValidRequest = 1'b1;
  #(PERIOD);
  oValidRequest = 1'b0;
  #(9*PERIOD);

  oData = 16'h3456;
  oAddress = 22'h00000B;
  oValidRequest = 1'b1;
  #(PERIOD);
  oValidRequest = 1'b0;
  #(9*PERIOD);

  oData = 16'h4567;
  oAddress = 22'h00000C;
  oValidRequest = 1'b1;
  #(PERIOD);
  oValidRequest = 1'b0;
  #(9*PERIOD);

  oData = 16'h5678;
  oAddress = 22'h00000D;
  oValidRequest = 1'b1;
  #(PERIOD);
  oValidRequest = 1'b0;
  #(9*PERIOD);

  /////////////////////////////////////////////////////////////
  // SOME WRITES ARE MISSING BUT WE'RE GONNA READ
  /////////////////////////////////////////////////////////////

  oWrite = 1'b0;

  oAddress = 22'h000000;
  oValidRequest = 1'b1;
  #(PERIOD);
  oValidRequest = 1'b0;
  #(9*PERIOD);

  oAddress = 22'h000001;
  oValidRequest = 1'b1;
  #(PERIOD);
  oValidRequest = 1'b0;
  #(9*PERIOD);

  oAddress = 22'h000002;
  oValidRequest = 1'b1;
  #(PERIOD);
  oValidRequest = 1'b0;
  #(9*PERIOD);

  oAddress = 22'h000003;
  oValidRequest = 1'b1;
  #(PERIOD);
  oValidRequest = 1'b0;
  #(9*PERIOD);

  oAddress = 22'h0C0004;
  oValidRequest = 1'b1;
  #(PERIOD);
  oValidRequest = 1'b0;
  #(9*PERIOD);


  $finish;
end

//////////////////////
// sram_read_simulator
always @ ( posedge  clk) begin

  if (!oWrite && !cs && ras && !cas && we) begin

    case (oAddress)
      0: ioDataFromSRAM = 16'hCCCC;
      1: ioDataFromSRAM = 16'h0001;
      2: ioDataFromSRAM = 16'hBBBB;
      3: ioDataFromSRAM = 16'h1234;
      4: ioDataFromSRAM = 16'h2345;
      5: ioDataFromSRAM = 16'h3456;
      6: ioDataFromSRAM = 16'h4567;
      7: ioDataFromSRAM = 16'hEEEE;
      8: ioDataFromSRAM = 16'h001C;
      9: ioDataFromSRAM = 16'h1234;
      10: ioDataFromSRAM = 16'h2345;
      11: ioDataFromSRAM = 16'h3456;
      12: ioDataFromSRAM = 16'h4567;
      13: ioDataFromSRAM = 16'h5678;
      14: ioDataFromSRAM = 16'h6789;
      15: ioDataFromSRAM = 16'h789A;
      16: ioDataFromSRAM = 16'h89AB;
      17: ioDataFromSRAM = 16'h9ABC;
      18: ioDataFromSRAM = 16'hABCD;
      19: ioDataFromSRAM = 16'hBCDE;
      20: ioDataFromSRAM = 16'hCDEF;
      21: ioDataFromSRAM = 16'h9999;
      22: ioDataFromSRAM = 16'h1234;
      23: ioDataFromSRAM = 16'h2345;
      24: ioDataFromSRAM = 16'h3456;
      25: ioDataFromSRAM = 16'h4567;
      26: ioDataFromSRAM = 16'h5678;
      27: ioDataFromSRAM = 16'h6789;
      28: ioDataFromSRAM = 16'hFFFF;
      default: ioDataFromSRAM = 16'hFFFF;
    endcase

  end // !oWrite

end


endmodule
