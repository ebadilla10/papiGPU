`include "../rtl/papiGPU.v"

`timescale 1ns / 1ps

module papiGPU_tb;

reg clk = 0;
reg rst = 0;

reg Rx = 1;

reg [15:0] Data = 16'hzzzz;
wire [15:0] wData;
assign wData = Data;

wire outClock;
wire ras;
wire cas;
wire we;
wire [11:0] wRamMemAddr;

reg [1:0] sram_read_state = 2'b00;


//////////////////
// Begin the Clock
parameter PERIOD = 31.25; //31.25ns = 32MHz
always begin
  clk = 1'b0;
  #(PERIOD/2) clk = 1'b1;
  #(PERIOD/2);
end

// For UART
parameter BIT_PERIOD = 1085;

//////////////////
// INSTANCES
papiGPU papiGPU_complete(
  .iClock(clk),
  .iReset(rst),

  .ioRamData(wData),
  .oRamMemAddr(wRamMemAddr),

  .iRx(Rx),

  .oClock(outClock),
  .oRASN(ras),
  .oCASN(cas),
  .oWEn(we)
);

// Initial the test
initial begin

  $dumpfile("sram_tb.vcd");
  $dumpvars(0, papiGPU_tb);

  #110000 // Wait for SRAM init

//  _____       _ _   _       _ _
// |_   _|     (_) | (_)     | (_)
//   | |  _ __  _| |_ _  __ _| |_ _______
//   | | | '_ \| | __| |/ _` | | |_  / _ \
//  _| |_| | | | | |_| | (_| | | |/ /  __/
// |_____|_| |_|_|\__|_|\__,_|_|_/___\___|

  ///////
  // AAAA
  ///////
  Rx = 0; #BIT_PERIOD;
  Rx = 0; #BIT_PERIOD; Rx = 1; #BIT_PERIOD; Rx = 0; #BIT_PERIOD;
  Rx = 1; #BIT_PERIOD; Rx = 0; #BIT_PERIOD; Rx = 1; #BIT_PERIOD;
  Rx = 0; #BIT_PERIOD; Rx = 1; #BIT_PERIOD;
  Rx = 1; #BIT_PERIOD;

  Rx = 0; #BIT_PERIOD;
  Rx = 0; #BIT_PERIOD; Rx = 1; #BIT_PERIOD; Rx = 0; #BIT_PERIOD;
  Rx = 1; #BIT_PERIOD; Rx = 0; #BIT_PERIOD; Rx = 1; #BIT_PERIOD;
  Rx = 0; #BIT_PERIOD; Rx = 1; #BIT_PERIOD;
  Rx = 1; #BIT_PERIOD;

  // Wait answer
  #(20 * BIT_PERIOD);

  ///////
  // 0000
  ///////
  Rx = 0; #BIT_PERIOD;
  Rx = 0; #BIT_PERIOD; Rx = 0; #BIT_PERIOD; Rx = 0; #BIT_PERIOD;
  Rx = 0; #BIT_PERIOD; Rx = 0; #BIT_PERIOD; Rx = 0; #BIT_PERIOD;
  Rx = 0; #BIT_PERIOD; Rx = 0; #BIT_PERIOD;
  Rx = 1; #BIT_PERIOD;

  Rx = 0; #BIT_PERIOD;
  Rx = 0; #BIT_PERIOD; Rx = 0; #BIT_PERIOD; Rx = 0; #BIT_PERIOD;
  Rx = 0; #BIT_PERIOD; Rx = 0; #BIT_PERIOD; Rx = 0; #BIT_PERIOD;
  Rx = 0; #BIT_PERIOD; Rx = 0; #BIT_PERIOD;
  Rx = 1; #BIT_PERIOD;

  ///////
  // CCCC
  ///////
  Rx = 0; #BIT_PERIOD;
  Rx = 0; #BIT_PERIOD; Rx = 0; #BIT_PERIOD; Rx = 1; #BIT_PERIOD;
  Rx = 1; #BIT_PERIOD; Rx = 0; #BIT_PERIOD; Rx = 0; #BIT_PERIOD;
  Rx = 1; #BIT_PERIOD; Rx = 1; #BIT_PERIOD;
  Rx = 1; #BIT_PERIOD;

  Rx = 0; #BIT_PERIOD;
  Rx = 0; #BIT_PERIOD; Rx = 0; #BIT_PERIOD; Rx = 1; #BIT_PERIOD;
  Rx = 1; #BIT_PERIOD; Rx = 0; #BIT_PERIOD; Rx = 0; #BIT_PERIOD;
  Rx = 1; #BIT_PERIOD; Rx = 1; #BIT_PERIOD;
  Rx = 1; #BIT_PERIOD;

  ///////
  // 0000
  ///////
  Rx = 0; #BIT_PERIOD;
  Rx = 0; #BIT_PERIOD; Rx = 0; #BIT_PERIOD; Rx = 0; #BIT_PERIOD;
  Rx = 0; #BIT_PERIOD; Rx = 0; #BIT_PERIOD; Rx = 0; #BIT_PERIOD;
  Rx = 0; #BIT_PERIOD; Rx = 0; #BIT_PERIOD;
  Rx = 1; #BIT_PERIOD;

  Rx = 0; #BIT_PERIOD;
  Rx = 0; #BIT_PERIOD; Rx = 0; #BIT_PERIOD; Rx = 0; #BIT_PERIOD;
  Rx = 0; #BIT_PERIOD; Rx = 0; #BIT_PERIOD; Rx = 0; #BIT_PERIOD;
  Rx = 0; #BIT_PERIOD; Rx = 0; #BIT_PERIOD;
  Rx = 1; #BIT_PERIOD;

  ///////
  // FFFF
  ///////
  Rx = 0; #BIT_PERIOD;
  Rx = 1; #BIT_PERIOD; Rx = 1; #BIT_PERIOD; Rx = 1; #BIT_PERIOD;
  Rx = 1; #BIT_PERIOD; Rx = 1; #BIT_PERIOD; Rx = 1; #BIT_PERIOD;
  Rx = 1; #BIT_PERIOD; Rx = 1; #BIT_PERIOD;
  Rx = 1; #BIT_PERIOD;

  Rx = 0; #BIT_PERIOD;
  Rx = 1; #BIT_PERIOD; Rx = 1; #BIT_PERIOD; Rx = 1; #BIT_PERIOD;
  Rx = 1; #BIT_PERIOD; Rx = 1; #BIT_PERIOD; Rx = 1; #BIT_PERIOD;
  Rx = 1; #BIT_PERIOD; Rx = 1; #BIT_PERIOD;
  Rx = 1; #BIT_PERIOD;

  // Wait answer
  #(20 * BIT_PERIOD);

//  _____
// / ____|
// | |     __ _ _ __ ___   ___ _ __ __ _
// | |    / _` | '_ ` _ \ / _ \ '__/ _` |
// | |___| (_| | | | | | |  __/ | | (_| |
// \_____\__,_|_| |_| |_|\___|_|  \__,_ |

///////
// BBBB
///////
Rx = 0; #BIT_PERIOD;
Rx = 1; #BIT_PERIOD; Rx = 1; #BIT_PERIOD; Rx = 0; #BIT_PERIOD;
Rx = 1; #BIT_PERIOD; Rx = 1; #BIT_PERIOD; Rx = 1; #BIT_PERIOD;
Rx = 0; #BIT_PERIOD; Rx = 1; #BIT_PERIOD;
Rx = 1; #BIT_PERIOD;

Rx = 0; #BIT_PERIOD;
Rx = 1; #BIT_PERIOD; Rx = 1; #BIT_PERIOD; Rx = 0; #BIT_PERIOD;
Rx = 1; #BIT_PERIOD; Rx = 1; #BIT_PERIOD; Rx = 1; #BIT_PERIOD;
Rx = 0; #BIT_PERIOD; Rx = 1; #BIT_PERIOD;
Rx = 1; #BIT_PERIOD;

// Wait answer
#(20 * BIT_PERIOD);

///////
// 0002
///////
Rx = 0; #BIT_PERIOD;
Rx = 0; #BIT_PERIOD; Rx = 0; #BIT_PERIOD; Rx = 0; #BIT_PERIOD;
Rx = 0; #BIT_PERIOD; Rx = 0; #BIT_PERIOD; Rx = 0; #BIT_PERIOD;
Rx = 0; #BIT_PERIOD; Rx = 0; #BIT_PERIOD;
Rx = 1; #BIT_PERIOD;

Rx = 0; #BIT_PERIOD;
Rx = 0; #BIT_PERIOD; Rx = 1; #BIT_PERIOD; Rx = 0; #BIT_PERIOD;
Rx = 0; #BIT_PERIOD; Rx = 0; #BIT_PERIOD; Rx = 0; #BIT_PERIOD;
Rx = 0; #BIT_PERIOD; Rx = 0; #BIT_PERIOD;
Rx = 1; #BIT_PERIOD;

///////
// BBBB
///////
Rx = 0; #BIT_PERIOD;
Rx = 1; #BIT_PERIOD; Rx = 1; #BIT_PERIOD; Rx = 0; #BIT_PERIOD;
Rx = 1; #BIT_PERIOD; Rx = 1; #BIT_PERIOD; Rx = 1; #BIT_PERIOD;
Rx = 0; #BIT_PERIOD; Rx = 1; #BIT_PERIOD;
Rx = 1; #BIT_PERIOD;

Rx = 0; #BIT_PERIOD;
Rx = 1; #BIT_PERIOD; Rx = 1; #BIT_PERIOD; Rx = 0; #BIT_PERIOD;
Rx = 1; #BIT_PERIOD; Rx = 1; #BIT_PERIOD; Rx = 1; #BIT_PERIOD;
Rx = 0; #BIT_PERIOD; Rx = 1; #BIT_PERIOD;
Rx = 1; #BIT_PERIOD;

///////
// 1234 Vx
///////
Rx = 0; #BIT_PERIOD;
Rx = 0; #BIT_PERIOD; Rx = 1; #BIT_PERIOD; Rx = 0; #BIT_PERIOD;
Rx = 0; #BIT_PERIOD; Rx = 1; #BIT_PERIOD; Rx = 0; #BIT_PERIOD;
Rx = 0; #BIT_PERIOD; Rx = 0; #BIT_PERIOD;
Rx = 1; #BIT_PERIOD;

Rx = 0; #BIT_PERIOD;
Rx = 0; #BIT_PERIOD; Rx = 0; #BIT_PERIOD; Rx = 1; #BIT_PERIOD;
Rx = 0; #BIT_PERIOD; Rx = 1; #BIT_PERIOD; Rx = 1; #BIT_PERIOD;
Rx = 0; #BIT_PERIOD; Rx = 0; #BIT_PERIOD;
Rx = 1; #BIT_PERIOD;

///////
// 2345 Vy
///////
Rx = 0; #BIT_PERIOD;
Rx = 1; #BIT_PERIOD; Rx = 1; #BIT_PERIOD; Rx = 0; #BIT_PERIOD;
Rx = 0; #BIT_PERIOD; Rx = 0; #BIT_PERIOD; Rx = 1; #BIT_PERIOD;
Rx = 0; #BIT_PERIOD; Rx = 0; #BIT_PERIOD;
Rx = 1; #BIT_PERIOD;

Rx = 0; #BIT_PERIOD;
Rx = 1; #BIT_PERIOD; Rx = 0; #BIT_PERIOD; Rx = 1; #BIT_PERIOD;
Rx = 0; #BIT_PERIOD; Rx = 0; #BIT_PERIOD; Rx = 0; #BIT_PERIOD;
Rx = 1; #BIT_PERIOD; Rx = 0; #BIT_PERIOD;
Rx = 1; #BIT_PERIOD;

///////
// 3456 Vz
///////
Rx = 0; #BIT_PERIOD;
Rx = 0; #BIT_PERIOD; Rx = 0; #BIT_PERIOD; Rx = 1; #BIT_PERIOD;
Rx = 0; #BIT_PERIOD; Rx = 1; #BIT_PERIOD; Rx = 1; #BIT_PERIOD;
Rx = 0; #BIT_PERIOD; Rx = 0; #BIT_PERIOD;
Rx = 1; #BIT_PERIOD;

Rx = 0; #BIT_PERIOD;
Rx = 0; #BIT_PERIOD; Rx = 1; #BIT_PERIOD; Rx = 1; #BIT_PERIOD;
Rx = 0; #BIT_PERIOD; Rx = 1; #BIT_PERIOD; Rx = 0; #BIT_PERIOD;
Rx = 1; #BIT_PERIOD; Rx = 0; #BIT_PERIOD;
Rx = 1; #BIT_PERIOD;

///////
// 4567 Dc
///////
Rx = 0; #BIT_PERIOD;
Rx = 1; #BIT_PERIOD; Rx = 0; #BIT_PERIOD; Rx = 1; #BIT_PERIOD;
Rx = 0; #BIT_PERIOD; Rx = 0; #BIT_PERIOD; Rx = 0; #BIT_PERIOD;
Rx = 1; #BIT_PERIOD; Rx = 0; #BIT_PERIOD;
Rx = 1; #BIT_PERIOD;

Rx = 0; #BIT_PERIOD;
Rx = 1; #BIT_PERIOD; Rx = 1; #BIT_PERIOD; Rx = 1; #BIT_PERIOD;
Rx = 0; #BIT_PERIOD; Rx = 0; #BIT_PERIOD; Rx = 1; #BIT_PERIOD;
Rx = 1; #BIT_PERIOD; Rx = 0; #BIT_PERIOD;
Rx = 1; #BIT_PERIOD;

///////
// FFFF
///////
Rx = 0; #BIT_PERIOD;
Rx = 1; #BIT_PERIOD; Rx = 1; #BIT_PERIOD; Rx = 1; #BIT_PERIOD;
Rx = 1; #BIT_PERIOD; Rx = 1; #BIT_PERIOD; Rx = 1; #BIT_PERIOD;
Rx = 1; #BIT_PERIOD; Rx = 1; #BIT_PERIOD;
Rx = 1; #BIT_PERIOD;

Rx = 0; #BIT_PERIOD;
Rx = 1; #BIT_PERIOD; Rx = 1; #BIT_PERIOD; Rx = 1; #BIT_PERIOD;
Rx = 1; #BIT_PERIOD; Rx = 1; #BIT_PERIOD; Rx = 1; #BIT_PERIOD;
Rx = 1; #BIT_PERIOD; Rx = 1; #BIT_PERIOD;
Rx = 1; #BIT_PERIOD;

// Wait answer
#(20 * BIT_PERIOD);

//   ____  _     _           _
//  / __ \| |   (_)         | |
// | |  | | |__  _  ___  ___| |_
// | |  | | '_ \| |/ _ \/ __| __|
// | |__| | |_) | |  __/ (__| |_
//  \____/|_.__/| |\___|\___|\__|
//             _/ |
//            |__/

///////
// EEEE
///////
Rx = 0; #BIT_PERIOD;
Rx = 0; #BIT_PERIOD; Rx = 1; #BIT_PERIOD; Rx = 1; #BIT_PERIOD;
Rx = 1; #BIT_PERIOD; Rx = 0; #BIT_PERIOD; Rx = 1; #BIT_PERIOD;
Rx = 1; #BIT_PERIOD; Rx = 1; #BIT_PERIOD;
Rx = 1; #BIT_PERIOD;

Rx = 0; #BIT_PERIOD;
Rx = 0; #BIT_PERIOD; Rx = 1; #BIT_PERIOD; Rx = 1; #BIT_PERIOD;
Rx = 1; #BIT_PERIOD; Rx = 0; #BIT_PERIOD; Rx = 1; #BIT_PERIOD;
Rx = 1; #BIT_PERIOD; Rx = 1; #BIT_PERIOD;
Rx = 1; #BIT_PERIOD;

// Wait answer
#(20 * BIT_PERIOD);

///////
// 0007
///////
Rx = 0; #BIT_PERIOD;
Rx = 0; #BIT_PERIOD; Rx = 0; #BIT_PERIOD; Rx = 0; #BIT_PERIOD;
Rx = 0; #BIT_PERIOD; Rx = 0; #BIT_PERIOD; Rx = 0; #BIT_PERIOD;
Rx = 0; #BIT_PERIOD; Rx = 0; #BIT_PERIOD;
Rx = 1; #BIT_PERIOD;

Rx = 0; #BIT_PERIOD;
Rx = 1; #BIT_PERIOD; Rx = 1; #BIT_PERIOD; Rx = 1; #BIT_PERIOD;
Rx = 0; #BIT_PERIOD; Rx = 0; #BIT_PERIOD; Rx = 0; #BIT_PERIOD;
Rx = 0; #BIT_PERIOD; Rx = 0; #BIT_PERIOD;
Rx = 1; #BIT_PERIOD;

///////
// EEEE
///////
Rx = 0; #BIT_PERIOD;
Rx = 0; #BIT_PERIOD; Rx = 1; #BIT_PERIOD; Rx = 1; #BIT_PERIOD;
Rx = 1; #BIT_PERIOD; Rx = 0; #BIT_PERIOD; Rx = 1; #BIT_PERIOD;
Rx = 1; #BIT_PERIOD; Rx = 1; #BIT_PERIOD;
Rx = 1; #BIT_PERIOD;

Rx = 0; #BIT_PERIOD;
Rx = 0; #BIT_PERIOD; Rx = 1; #BIT_PERIOD; Rx = 1; #BIT_PERIOD;
Rx = 1; #BIT_PERIOD; Rx = 0; #BIT_PERIOD; Rx = 1; #BIT_PERIOD;
Rx = 1; #BIT_PERIOD; Rx = 1; #BIT_PERIOD;
Rx = 1; #BIT_PERIOD;

///////
// 0000
///////
Rx = 0; #BIT_PERIOD;
Rx = 0; #BIT_PERIOD; Rx = 0; #BIT_PERIOD; Rx = 0; #BIT_PERIOD;
Rx = 0; #BIT_PERIOD; Rx = 0; #BIT_PERIOD; Rx = 0; #BIT_PERIOD;
Rx = 0; #BIT_PERIOD; Rx = 0; #BIT_PERIOD;
Rx = 1; #BIT_PERIOD;

Rx = 0; #BIT_PERIOD;
Rx = 0; #BIT_PERIOD; Rx = 0; #BIT_PERIOD; Rx = 0; #BIT_PERIOD;
Rx = 0; #BIT_PERIOD; Rx = 0; #BIT_PERIOD; Rx = 0; #BIT_PERIOD;
Rx = 0; #BIT_PERIOD; Rx = 0; #BIT_PERIOD;
Rx = 1; #BIT_PERIOD;

///////
// 1111 Cos Yaw
///////
Rx = 0; #BIT_PERIOD;
Rx = 1; #BIT_PERIOD; Rx = 0; #BIT_PERIOD; Rx = 0; #BIT_PERIOD;
Rx = 0; #BIT_PERIOD; Rx = 1; #BIT_PERIOD; Rx = 0; #BIT_PERIOD;
Rx = 0; #BIT_PERIOD; Rx = 0; #BIT_PERIOD;
Rx = 1; #BIT_PERIOD;

Rx = 0; #BIT_PERIOD;
Rx = 1; #BIT_PERIOD; Rx = 0; #BIT_PERIOD; Rx = 0; #BIT_PERIOD;
Rx = 0; #BIT_PERIOD; Rx = 1; #BIT_PERIOD; Rx = 0; #BIT_PERIOD;
Rx = 0; #BIT_PERIOD; Rx = 0; #BIT_PERIOD;
Rx = 1; #BIT_PERIOD;

///////
// 2222 Cos Pitch
///////

Rx = 0; #BIT_PERIOD;
Rx = 0; #BIT_PERIOD; Rx = 1; #BIT_PERIOD; Rx = 0; #BIT_PERIOD;
Rx = 0; #BIT_PERIOD; Rx = 0; #BIT_PERIOD; Rx = 1; #BIT_PERIOD;
Rx = 0; #BIT_PERIOD; Rx = 0; #BIT_PERIOD;
Rx = 1; #BIT_PERIOD;

Rx = 0; #BIT_PERIOD;
Rx = 0; #BIT_PERIOD; Rx = 1; #BIT_PERIOD; Rx = 0; #BIT_PERIOD;
Rx = 0; #BIT_PERIOD; Rx = 0; #BIT_PERIOD; Rx = 1; #BIT_PERIOD;
Rx = 0; #BIT_PERIOD; Rx = 0; #BIT_PERIOD;
Rx = 1; #BIT_PERIOD;

///////
// 3333 Cos Roll
///////

Rx = 0; #BIT_PERIOD;
Rx = 1; #BIT_PERIOD; Rx = 1; #BIT_PERIOD; Rx = 0; #BIT_PERIOD;
Rx = 0; #BIT_PERIOD; Rx = 1; #BIT_PERIOD; Rx = 1; #BIT_PERIOD;
Rx = 0; #BIT_PERIOD; Rx = 0; #BIT_PERIOD;
Rx = 1; #BIT_PERIOD;

Rx = 0; #BIT_PERIOD;
Rx = 1; #BIT_PERIOD; Rx = 1; #BIT_PERIOD; Rx = 0; #BIT_PERIOD;
Rx = 0; #BIT_PERIOD; Rx = 1; #BIT_PERIOD; Rx = 1; #BIT_PERIOD;
Rx = 0; #BIT_PERIOD; Rx = 0; #BIT_PERIOD;
Rx = 1; #BIT_PERIOD;

///////
// 4444 Sen Yaw
///////

Rx = 0; #BIT_PERIOD;
Rx = 0; #BIT_PERIOD; Rx = 0; #BIT_PERIOD; Rx = 1; #BIT_PERIOD;
Rx = 0; #BIT_PERIOD; Rx = 0; #BIT_PERIOD; Rx = 0; #BIT_PERIOD;
Rx = 1; #BIT_PERIOD; Rx = 0; #BIT_PERIOD;
Rx = 1; #BIT_PERIOD;

Rx = 0; #BIT_PERIOD;
Rx = 0; #BIT_PERIOD; Rx = 0; #BIT_PERIOD; Rx = 1; #BIT_PERIOD;
Rx = 0; #BIT_PERIOD; Rx = 0; #BIT_PERIOD; Rx = 0; #BIT_PERIOD;
Rx = 1; #BIT_PERIOD; Rx = 0; #BIT_PERIOD;
Rx = 1; #BIT_PERIOD;

///////
// 5555 Sen Pitch
///////

Rx = 0; #BIT_PERIOD;
Rx = 1; #BIT_PERIOD; Rx = 0; #BIT_PERIOD; Rx = 1; #BIT_PERIOD;
Rx = 0; #BIT_PERIOD; Rx = 1; #BIT_PERIOD; Rx = 0; #BIT_PERIOD;
Rx = 1; #BIT_PERIOD; Rx = 0; #BIT_PERIOD;
Rx = 1; #BIT_PERIOD;

Rx = 0; #BIT_PERIOD;
Rx = 1; #BIT_PERIOD; Rx = 0; #BIT_PERIOD; Rx = 1; #BIT_PERIOD;
Rx = 0; #BIT_PERIOD; Rx = 1; #BIT_PERIOD; Rx = 0; #BIT_PERIOD;
Rx = 1; #BIT_PERIOD; Rx = 0; #BIT_PERIOD;
Rx = 1; #BIT_PERIOD;

///////
// 6666 Sen Roll
///////

Rx = 0; #BIT_PERIOD;
Rx = 0; #BIT_PERIOD; Rx = 1; #BIT_PERIOD; Rx = 1; #BIT_PERIOD;
Rx = 0; #BIT_PERIOD; Rx = 0; #BIT_PERIOD; Rx = 1; #BIT_PERIOD;
Rx = 1; #BIT_PERIOD; Rx = 0; #BIT_PERIOD;
Rx = 1; #BIT_PERIOD;

Rx = 0; #BIT_PERIOD;
Rx = 0; #BIT_PERIOD; Rx = 1; #BIT_PERIOD; Rx = 1; #BIT_PERIOD;
Rx = 0; #BIT_PERIOD; Rx = 0; #BIT_PERIOD; Rx = 1; #BIT_PERIOD;
Rx = 1; #BIT_PERIOD; Rx = 0; #BIT_PERIOD;
Rx = 1; #BIT_PERIOD;

///////
// 7777 Scale X
///////

Rx = 0; #BIT_PERIOD;
Rx = 1; #BIT_PERIOD; Rx = 1; #BIT_PERIOD; Rx = 1; #BIT_PERIOD;
Rx = 0; #BIT_PERIOD; Rx = 1; #BIT_PERIOD; Rx = 1; #BIT_PERIOD;
Rx = 1; #BIT_PERIOD; Rx = 0; #BIT_PERIOD;
Rx = 1; #BIT_PERIOD;

Rx = 0; #BIT_PERIOD;
Rx = 1; #BIT_PERIOD; Rx = 1; #BIT_PERIOD; Rx = 1; #BIT_PERIOD;
Rx = 0; #BIT_PERIOD; Rx = 1; #BIT_PERIOD; Rx = 1; #BIT_PERIOD;
Rx = 1; #BIT_PERIOD; Rx = 0; #BIT_PERIOD;
Rx = 1; #BIT_PERIOD;

///////
// 8888 Scale Y
///////

Rx = 0; #BIT_PERIOD;
Rx = 0; #BIT_PERIOD; Rx = 0; #BIT_PERIOD; Rx = 0; #BIT_PERIOD;
Rx = 1; #BIT_PERIOD; Rx = 0; #BIT_PERIOD; Rx = 0; #BIT_PERIOD;
Rx = 0; #BIT_PERIOD; Rx = 1; #BIT_PERIOD;
Rx = 1; #BIT_PERIOD;

Rx = 0; #BIT_PERIOD;
Rx = 0; #BIT_PERIOD; Rx = 0; #BIT_PERIOD; Rx = 0; #BIT_PERIOD;
Rx = 1; #BIT_PERIOD; Rx = 0; #BIT_PERIOD; Rx = 0; #BIT_PERIOD;
Rx = 0; #BIT_PERIOD; Rx = 1; #BIT_PERIOD;
Rx = 1; #BIT_PERIOD;

///////
// 9999 Scale Z
///////

Rx = 0; #BIT_PERIOD;
Rx = 1; #BIT_PERIOD; Rx = 0; #BIT_PERIOD; Rx = 0; #BIT_PERIOD;
Rx = 1; #BIT_PERIOD; Rx = 1; #BIT_PERIOD; Rx = 0; #BIT_PERIOD;
Rx = 0; #BIT_PERIOD; Rx = 1; #BIT_PERIOD;
Rx = 1; #BIT_PERIOD;

Rx = 0; #BIT_PERIOD;
Rx = 1; #BIT_PERIOD; Rx = 0; #BIT_PERIOD; Rx = 0; #BIT_PERIOD;
Rx = 1; #BIT_PERIOD; Rx = 1; #BIT_PERIOD; Rx = 0; #BIT_PERIOD;
Rx = 0; #BIT_PERIOD; Rx = 1; #BIT_PERIOD;
Rx = 1; #BIT_PERIOD;

///////
// AAAA Trans X
///////

Rx = 0; #BIT_PERIOD;
Rx = 0; #BIT_PERIOD; Rx = 1; #BIT_PERIOD; Rx = 0; #BIT_PERIOD;
Rx = 1; #BIT_PERIOD; Rx = 0; #BIT_PERIOD; Rx = 1; #BIT_PERIOD;
Rx = 0; #BIT_PERIOD; Rx = 1; #BIT_PERIOD;
Rx = 1; #BIT_PERIOD;

Rx = 0; #BIT_PERIOD;
Rx = 0; #BIT_PERIOD; Rx = 1; #BIT_PERIOD; Rx = 0; #BIT_PERIOD;
Rx = 1; #BIT_PERIOD; Rx = 0; #BIT_PERIOD; Rx = 1; #BIT_PERIOD;
Rx = 0; #BIT_PERIOD; Rx = 1; #BIT_PERIOD;
Rx = 1; #BIT_PERIOD;

///////
// BBBB Trans Y
///////

Rx = 0; #BIT_PERIOD;
Rx = 1; #BIT_PERIOD; Rx = 1; #BIT_PERIOD; Rx = 0; #BIT_PERIOD;
Rx = 1; #BIT_PERIOD; Rx = 1; #BIT_PERIOD; Rx = 1; #BIT_PERIOD;
Rx = 0; #BIT_PERIOD; Rx = 1; #BIT_PERIOD;
Rx = 1; #BIT_PERIOD;

Rx = 0; #BIT_PERIOD;
Rx = 1; #BIT_PERIOD; Rx = 1; #BIT_PERIOD; Rx = 0; #BIT_PERIOD;
Rx = 1; #BIT_PERIOD; Rx = 1; #BIT_PERIOD; Rx = 1; #BIT_PERIOD;
Rx = 0; #BIT_PERIOD; Rx = 1; #BIT_PERIOD;
Rx = 1; #BIT_PERIOD;

///////
// CCCC Trans Z
///////

Rx = 0; #BIT_PERIOD;
Rx = 0; #BIT_PERIOD; Rx = 0; #BIT_PERIOD; Rx = 1; #BIT_PERIOD;
Rx = 1; #BIT_PERIOD; Rx = 0; #BIT_PERIOD; Rx = 0; #BIT_PERIOD;
Rx = 1; #BIT_PERIOD; Rx = 1; #BIT_PERIOD;
Rx = 1; #BIT_PERIOD;

Rx = 0; #BIT_PERIOD;
Rx = 0; #BIT_PERIOD; Rx = 0; #BIT_PERIOD; Rx = 1; #BIT_PERIOD;
Rx = 1; #BIT_PERIOD; Rx = 0; #BIT_PERIOD; Rx = 0; #BIT_PERIOD;
Rx = 1; #BIT_PERIOD; Rx = 1; #BIT_PERIOD;
Rx = 1; #BIT_PERIOD;

///////
// FFFF
///////
Rx = 0; #BIT_PERIOD;
Rx = 1; #BIT_PERIOD; Rx = 1; #BIT_PERIOD; Rx = 1; #BIT_PERIOD;
Rx = 1; #BIT_PERIOD; Rx = 1; #BIT_PERIOD; Rx = 1; #BIT_PERIOD;
Rx = 1; #BIT_PERIOD; Rx = 1; #BIT_PERIOD;
Rx = 1; #BIT_PERIOD;

Rx = 0; #BIT_PERIOD;
Rx = 1; #BIT_PERIOD; Rx = 1; #BIT_PERIOD; Rx = 1; #BIT_PERIOD;
Rx = 1; #BIT_PERIOD; Rx = 1; #BIT_PERIOD; Rx = 1; #BIT_PERIOD;
Rx = 1; #BIT_PERIOD; Rx = 1; #BIT_PERIOD;
Rx = 1; #BIT_PERIOD;

// Wait answer
#(20 * BIT_PERIOD);

// __      __       _   _
// \ \    / /      | | (_)
//  \ \  / /__ _ __| |_ _  ___ ___  ___
//   \ \/ / _ \ '__| __| |/ __/ _ \/ __|
//    \  /  __/ |  | |_| | (_|  __/\__ \
//     \/ \___|_|   \__|_|\___\___||___/

///////
// 9999
///////

Rx = 0; #BIT_PERIOD;
Rx = 1; #BIT_PERIOD; Rx = 0; #BIT_PERIOD; Rx = 0; #BIT_PERIOD;
Rx = 1; #BIT_PERIOD; Rx = 1; #BIT_PERIOD; Rx = 0; #BIT_PERIOD;
Rx = 0; #BIT_PERIOD; Rx = 1; #BIT_PERIOD;
Rx = 1; #BIT_PERIOD;

Rx = 0; #BIT_PERIOD;
Rx = 1; #BIT_PERIOD; Rx = 0; #BIT_PERIOD; Rx = 0; #BIT_PERIOD;
Rx = 1; #BIT_PERIOD; Rx = 1; #BIT_PERIOD; Rx = 0; #BIT_PERIOD;
Rx = 0; #BIT_PERIOD; Rx = 1; #BIT_PERIOD;
Rx = 1; #BIT_PERIOD;

// Wait answer
#(20 * BIT_PERIOD);

///////
// 0002 Objects
///////

Rx = 0; #BIT_PERIOD;
Rx = 0; #BIT_PERIOD; Rx = 0; #BIT_PERIOD; Rx = 0; #BIT_PERIOD;
Rx = 0; #BIT_PERIOD; Rx = 0; #BIT_PERIOD; Rx = 0; #BIT_PERIOD;
Rx = 0; #BIT_PERIOD; Rx = 0; #BIT_PERIOD;
Rx = 1; #BIT_PERIOD;

Rx = 0; #BIT_PERIOD;
Rx = 0; #BIT_PERIOD; Rx = 1; #BIT_PERIOD; Rx = 0; #BIT_PERIOD;
Rx = 0; #BIT_PERIOD; Rx = 0; #BIT_PERIOD; Rx = 0; #BIT_PERIOD;
Rx = 0; #BIT_PERIOD; Rx = 0; #BIT_PERIOD;
Rx = 1; #BIT_PERIOD;

///////
// 0015
///////

Rx = 0; #BIT_PERIOD;
Rx = 0; #BIT_PERIOD; Rx = 0; #BIT_PERIOD; Rx = 0; #BIT_PERIOD;
Rx = 0; #BIT_PERIOD; Rx = 0; #BIT_PERIOD; Rx = 0; #BIT_PERIOD;
Rx = 0; #BIT_PERIOD; Rx = 0; #BIT_PERIOD;
Rx = 1; #BIT_PERIOD;

Rx = 0; #BIT_PERIOD;
Rx = 1; #BIT_PERIOD; Rx = 0; #BIT_PERIOD; Rx = 1; #BIT_PERIOD;
Rx = 0; #BIT_PERIOD; Rx = 1; #BIT_PERIOD; Rx = 0; #BIT_PERIOD;
Rx = 0; #BIT_PERIOD; Rx = 0; #BIT_PERIOD;
Rx = 1; #BIT_PERIOD;

///////
// 9999
///////

Rx = 0; #BIT_PERIOD;
Rx = 1; #BIT_PERIOD; Rx = 0; #BIT_PERIOD; Rx = 0; #BIT_PERIOD;
Rx = 1; #BIT_PERIOD; Rx = 1; #BIT_PERIOD; Rx = 0; #BIT_PERIOD;
Rx = 0; #BIT_PERIOD; Rx = 1; #BIT_PERIOD;
Rx = 1; #BIT_PERIOD;

Rx = 0; #BIT_PERIOD;
Rx = 1; #BIT_PERIOD; Rx = 0; #BIT_PERIOD; Rx = 0; #BIT_PERIOD;
Rx = 1; #BIT_PERIOD; Rx = 1; #BIT_PERIOD; Rx = 0; #BIT_PERIOD;
Rx = 0; #BIT_PERIOD; Rx = 1; #BIT_PERIOD;
Rx = 1; #BIT_PERIOD;

///////
// 1111 X0
///////
Rx = 0; #BIT_PERIOD;
Rx = 1; #BIT_PERIOD; Rx = 0; #BIT_PERIOD; Rx = 0; #BIT_PERIOD;
Rx = 0; #BIT_PERIOD; Rx = 1; #BIT_PERIOD; Rx = 0; #BIT_PERIOD;
Rx = 0; #BIT_PERIOD; Rx = 0; #BIT_PERIOD;
Rx = 1; #BIT_PERIOD;

Rx = 0; #BIT_PERIOD;
Rx = 1; #BIT_PERIOD; Rx = 0; #BIT_PERIOD; Rx = 0; #BIT_PERIOD;
Rx = 0; #BIT_PERIOD; Rx = 1; #BIT_PERIOD; Rx = 0; #BIT_PERIOD;
Rx = 0; #BIT_PERIOD; Rx = 0; #BIT_PERIOD;
Rx = 1; #BIT_PERIOD;

///////
// 2222 Y0
///////

Rx = 0; #BIT_PERIOD;
Rx = 0; #BIT_PERIOD; Rx = 1; #BIT_PERIOD; Rx = 0; #BIT_PERIOD;
Rx = 0; #BIT_PERIOD; Rx = 0; #BIT_PERIOD; Rx = 1; #BIT_PERIOD;
Rx = 0; #BIT_PERIOD; Rx = 0; #BIT_PERIOD;
Rx = 1; #BIT_PERIOD;

Rx = 0; #BIT_PERIOD;
Rx = 0; #BIT_PERIOD; Rx = 1; #BIT_PERIOD; Rx = 0; #BIT_PERIOD;
Rx = 0; #BIT_PERIOD; Rx = 0; #BIT_PERIOD; Rx = 1; #BIT_PERIOD;
Rx = 0; #BIT_PERIOD; Rx = 0; #BIT_PERIOD;
Rx = 1; #BIT_PERIOD;

///////
// 3333 Z0
///////

Rx = 0; #BIT_PERIOD;
Rx = 1; #BIT_PERIOD; Rx = 1; #BIT_PERIOD; Rx = 0; #BIT_PERIOD;
Rx = 0; #BIT_PERIOD; Rx = 1; #BIT_PERIOD; Rx = 1; #BIT_PERIOD;
Rx = 0; #BIT_PERIOD; Rx = 0; #BIT_PERIOD;
Rx = 1; #BIT_PERIOD;

Rx = 0; #BIT_PERIOD;
Rx = 1; #BIT_PERIOD; Rx = 1; #BIT_PERIOD; Rx = 0; #BIT_PERIOD;
Rx = 0; #BIT_PERIOD; Rx = 1; #BIT_PERIOD; Rx = 1; #BIT_PERIOD;
Rx = 0; #BIT_PERIOD; Rx = 0; #BIT_PERIOD;
Rx = 1; #BIT_PERIOD;

///////
// 4444 X1
///////

Rx = 0; #BIT_PERIOD;
Rx = 0; #BIT_PERIOD; Rx = 0; #BIT_PERIOD; Rx = 1; #BIT_PERIOD;
Rx = 0; #BIT_PERIOD; Rx = 0; #BIT_PERIOD; Rx = 0; #BIT_PERIOD;
Rx = 1; #BIT_PERIOD; Rx = 0; #BIT_PERIOD;
Rx = 1; #BIT_PERIOD;

Rx = 0; #BIT_PERIOD;
Rx = 0; #BIT_PERIOD; Rx = 0; #BIT_PERIOD; Rx = 1; #BIT_PERIOD;
Rx = 0; #BIT_PERIOD; Rx = 0; #BIT_PERIOD; Rx = 0; #BIT_PERIOD;
Rx = 1; #BIT_PERIOD; Rx = 0; #BIT_PERIOD;
Rx = 1; #BIT_PERIOD;

///////
// 5555 Y1
///////

Rx = 0; #BIT_PERIOD;
Rx = 1; #BIT_PERIOD; Rx = 0; #BIT_PERIOD; Rx = 1; #BIT_PERIOD;
Rx = 0; #BIT_PERIOD; Rx = 1; #BIT_PERIOD; Rx = 0; #BIT_PERIOD;
Rx = 1; #BIT_PERIOD; Rx = 0; #BIT_PERIOD;
Rx = 1; #BIT_PERIOD;

Rx = 0; #BIT_PERIOD;
Rx = 1; #BIT_PERIOD; Rx = 0; #BIT_PERIOD; Rx = 1; #BIT_PERIOD;
Rx = 0; #BIT_PERIOD; Rx = 1; #BIT_PERIOD; Rx = 0; #BIT_PERIOD;
Rx = 1; #BIT_PERIOD; Rx = 0; #BIT_PERIOD;
Rx = 1; #BIT_PERIOD;

///////
// 6666 Z1
///////

Rx = 0; #BIT_PERIOD;
Rx = 0; #BIT_PERIOD; Rx = 1; #BIT_PERIOD; Rx = 1; #BIT_PERIOD;
Rx = 0; #BIT_PERIOD; Rx = 0; #BIT_PERIOD; Rx = 1; #BIT_PERIOD;
Rx = 1; #BIT_PERIOD; Rx = 0; #BIT_PERIOD;
Rx = 1; #BIT_PERIOD;

Rx = 0; #BIT_PERIOD;
Rx = 0; #BIT_PERIOD; Rx = 1; #BIT_PERIOD; Rx = 1; #BIT_PERIOD;
Rx = 0; #BIT_PERIOD; Rx = 0; #BIT_PERIOD; Rx = 1; #BIT_PERIOD;
Rx = 1; #BIT_PERIOD; Rx = 0; #BIT_PERIOD;
Rx = 1; #BIT_PERIOD;

///////
// FFFF
///////
Rx = 0; #BIT_PERIOD;
Rx = 1; #BIT_PERIOD; Rx = 1; #BIT_PERIOD; Rx = 1; #BIT_PERIOD;
Rx = 1; #BIT_PERIOD; Rx = 1; #BIT_PERIOD; Rx = 1; #BIT_PERIOD;
Rx = 1; #BIT_PERIOD; Rx = 1; #BIT_PERIOD;
Rx = 1; #BIT_PERIOD;

Rx = 0; #BIT_PERIOD;
Rx = 1; #BIT_PERIOD; Rx = 1; #BIT_PERIOD; Rx = 1; #BIT_PERIOD;
Rx = 1; #BIT_PERIOD; Rx = 1; #BIT_PERIOD; Rx = 1; #BIT_PERIOD;
Rx = 1; #BIT_PERIOD; Rx = 1; #BIT_PERIOD;
Rx = 1; #BIT_PERIOD;

// Wait answer
#(20 * BIT_PERIOD);

//   _____ _
//  / ____| |
// | |    | | ___  ___  ___
// | |    | |/ _ \/ __|/ _ \
// | |____| | (_) \__ \  __/
//  \_____|_|\___/|___/\___|

///////
// 8888
///////

Rx = 0; #BIT_PERIOD;
Rx = 0; #BIT_PERIOD; Rx = 0; #BIT_PERIOD; Rx = 0; #BIT_PERIOD;
Rx = 1; #BIT_PERIOD; Rx = 0; #BIT_PERIOD; Rx = 0; #BIT_PERIOD;
Rx = 0; #BIT_PERIOD; Rx = 1; #BIT_PERIOD;
Rx = 1; #BIT_PERIOD;

Rx = 0; #BIT_PERIOD;
Rx = 0; #BIT_PERIOD; Rx = 0; #BIT_PERIOD; Rx = 0; #BIT_PERIOD;
Rx = 1; #BIT_PERIOD; Rx = 0; #BIT_PERIOD; Rx = 0; #BIT_PERIOD;
Rx = 0; #BIT_PERIOD; Rx = 1; #BIT_PERIOD;
Rx = 1; #BIT_PERIOD;

// Wait answer
#(20 * BIT_PERIOD);

///////
// 0008
///////

Rx = 0; #BIT_PERIOD;
Rx = 0; #BIT_PERIOD; Rx = 0; #BIT_PERIOD; Rx = 0; #BIT_PERIOD;
Rx = 0; #BIT_PERIOD; Rx = 0; #BIT_PERIOD; Rx = 0; #BIT_PERIOD;
Rx = 0; #BIT_PERIOD; Rx = 0; #BIT_PERIOD;
Rx = 1; #BIT_PERIOD;

Rx = 0; #BIT_PERIOD;
Rx = 0; #BIT_PERIOD; Rx = 0; #BIT_PERIOD; Rx = 0; #BIT_PERIOD;
Rx = 1; #BIT_PERIOD; Rx = 0; #BIT_PERIOD; Rx = 0; #BIT_PERIOD;
Rx = 0; #BIT_PERIOD; Rx = 0; #BIT_PERIOD;
Rx = 1; #BIT_PERIOD;

///////
// 001C
///////

Rx = 0; #BIT_PERIOD;
Rx = 0; #BIT_PERIOD; Rx = 0; #BIT_PERIOD; Rx = 0; #BIT_PERIOD;
Rx = 0; #BIT_PERIOD; Rx = 0; #BIT_PERIOD; Rx = 0; #BIT_PERIOD;
Rx = 0; #BIT_PERIOD; Rx = 0; #BIT_PERIOD;
Rx = 1; #BIT_PERIOD;

Rx = 0; #BIT_PERIOD;
Rx = 0; #BIT_PERIOD; Rx = 0; #BIT_PERIOD; Rx = 1; #BIT_PERIOD;
Rx = 1; #BIT_PERIOD; Rx = 1; #BIT_PERIOD; Rx = 0; #BIT_PERIOD;
Rx = 0; #BIT_PERIOD; Rx = 0; #BIT_PERIOD;
Rx = 1; #BIT_PERIOD;

///////
// FFFF
///////
Rx = 0; #BIT_PERIOD;
Rx = 1; #BIT_PERIOD; Rx = 1; #BIT_PERIOD; Rx = 1; #BIT_PERIOD;
Rx = 1; #BIT_PERIOD; Rx = 1; #BIT_PERIOD; Rx = 1; #BIT_PERIOD;
Rx = 1; #BIT_PERIOD; Rx = 1; #BIT_PERIOD;
Rx = 1; #BIT_PERIOD;

Rx = 0; #BIT_PERIOD;
Rx = 1; #BIT_PERIOD; Rx = 1; #BIT_PERIOD; Rx = 1; #BIT_PERIOD;
Rx = 1; #BIT_PERIOD; Rx = 1; #BIT_PERIOD; Rx = 1; #BIT_PERIOD;
Rx = 1; #BIT_PERIOD; Rx = 1; #BIT_PERIOD;
Rx = 1; #BIT_PERIOD;

// Wait answer
#(20 * BIT_PERIOD);

//  _____       __               _
// |  __ \     / _|             | |
// | |__) |___| |_ _ __ ___  ___| |__
// |  _  // _ \  _| '__/ _ \/ __| '_ \
// | | \ \  __/ | | | |  __/\__ \ | | |
// |_|  \_\___|_| |_|  \___||___/_| |_|


///////
// 1234
///////

Rx = 0; #BIT_PERIOD;
Rx = 0; #BIT_PERIOD; Rx = 1; #BIT_PERIOD; Rx = 0; #BIT_PERIOD;
Rx = 0; #BIT_PERIOD; Rx = 1; #BIT_PERIOD; Rx = 0; #BIT_PERIOD;
Rx = 0; #BIT_PERIOD; Rx = 0; #BIT_PERIOD;
Rx = 1; #BIT_PERIOD;

Rx = 0; #BIT_PERIOD;
Rx = 0; #BIT_PERIOD; Rx = 0; #BIT_PERIOD; Rx = 1; #BIT_PERIOD;
Rx = 0; #BIT_PERIOD; Rx = 1; #BIT_PERIOD; Rx = 1; #BIT_PERIOD;
Rx = 0; #BIT_PERIOD; Rx = 0; #BIT_PERIOD;
Rx = 1; #BIT_PERIOD;


// Wait Refresh
#(350 * PERIOD);

  $finish;
end

//////////////////////
// sram_read_simulator
always @ ( posedge  outClock) begin

  if (sram_read_state == 2'b00) begin

    if (ras && !cas && we) begin
      sram_read_state = sram_read_state + 2'b01;
    end

  end
  else if (sram_read_state == 2'b01) begin
    #5;
    case (wRamMemAddr)
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

    sram_read_state = sram_read_state + 2'b01;
  end
  else begin
    #5;
    Data = 16'hzzzz;

    sram_read_state = 2'b00;
  end

  if (ras && !cas && we) begin



  end // !oWrite

end


endmodule
