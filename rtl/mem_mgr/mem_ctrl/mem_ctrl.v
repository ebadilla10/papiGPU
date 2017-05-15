`timescale 1ns / 1ps

module mem_ctrl(
  // Inputs
  input wire iClock,
  input wire iReset,

  // Outputs to Graphics Pipeline
  output reg        oEnable,
  output wire       oInitObj,
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

  // Inputs from SRAM
  inout [15:0] ioData,
  input wire   iValidRead, // ACK
  // Outputs to SRAM
  output reg [21:0] oAddress,
  output reg        oValidRequest, // REQ
  output reg        oWrite,

  // Inputs from UART
  input wire [7:0] iRxByte,
  input wire       iRxReady,
  input wire       iRxError,
  // Output to UART
  output reg [7:0] oTxByte,
  output reg       oTxReady
);

  // Memory control sizes
  parameter GLB_STATE_SIZE       = 3;
  parameter UART_SEND_STATE_SIZE = 1;
  parameter SUB_STATE_SIZE       = 2;

  // Global Memory Control States
  parameter GLB_WAIT_UART   = 3'b000;
  parameter GLB_SET_INIT    = 3'b001;
  parameter GLB_SET_CAM     = 3'b010;
  parameter GLB_SET_OBJ     = 3'b011;
  parameter GLB_SET_OBJ_VTX = 3'b100;
  parameter GLB_CLOSE_OBJ   = 3'b101;
  parameter GLB_CHG_TMATRIX = 3'b110;
  parameter GLB_REFRESH     = 3'b111;

  // UART Sending States
  parameter UART_TO_SEND  = 1'b0;
  parameter UART_TO_CLOSE = 1'b1;

  // General Sub-States, except for Refresh
  parameter SUB_RESPONSE_TO_APPROVAL = 2'b00;
  parameter SUB_SET_ADDRESS          = 2'b01;
  parameter SUB_WRITING_IN_SRAM      = 2'b10;

  // SRAM paremeters
  /** Same values set in papiGPU driver*/
  parameter INITIAL_ADDRESS    = 16'h0000;
  parameter INITIAL_BLOCK_SIZE = 16'h0002;
  parameter CAM_BLOCK_SIZE     = 16'h0005;
  parameter OBJ_BLOCK_SIZE     = 16'h000D;
  parameter CLS_OBJ_BLOCK_SIZE = 16'h0001;


  // Global Memory Control States Valid tags
  /** Same values set in papiGPU driver*/
  parameter REQUEST_VALID_TAG     = 16'hAAAA;
  parameter GPU_VALID_TAG         = 16'hCCCC;
  parameter CAM_VALID_TAG         = 16'hBBBB;
  parameter OBJ_VALID_TAG         = 16'hEEEE;
  parameter VRTX_VALID_TAG        = 16'h9999;
  parameter CLS_OBJ_VALID_TAG     = 16'h8888;
  parameter TMATRIX_VALID_TAG     = 16'hABCD;
  parameter REFRESH_VALID_TAG     = 16'h1234;
  parameter FINAL_BLOCK_VALID_TAG = 16'hFFFF;
  parameter ERROR_TAG             = 16'h1414;


  // State registers
  reg [GLB_STATE_SIZE-1:0]       rGlbState      = GLB_WAIT_UART;
  reg [UART_SEND_STATE_SIZE-1:0] rUartSendState = UART_TO_SEND;
  reg [SUB_STATE_SIZE-1:0]       rSubState      = SUB_RESPONSE_TO_APPROVAL;
  reg                            rSubStateChg   = 1'b0;

  // SRAM registers
  reg [15:0] rActualAddr = 16'h0000;
  reg [15:0] rStopAddr   = 16'h0000;
  reg [15:0] rOffsetAddr = 16'h0000;

  reg [15:0] rData           = 16'h0000;
  reg [15:0] rRespFinalState = 16'h0000;
  reg        rOffsetVertex   = 1'b0;
  reg        rTMatrixExcep   = 1'b0;

  assign ioData = (!oWrite) ? 8'bz : rData;


  /////////////////////////////////////////////////////////////////
  // rx_change: If data is received via UART this manage the Memory
  //            Control States
  always @ (posedge iRxReady) begin
    case(rGlbState)

      GLB_WAIT_UART: begin
        case(iRxByte)

          REQUEST_VALID_TAG: begin
            rGlbState <= GLB_SET_INIT;
            rOffsetAddr <= INITIAL_BLOCK_SIZE;
            rSubStateChg <= 1'b1;
          end

          CAM_VALID_TAG: begin
            rGlbState <= GLB_SET_CAM;
            rOffsetAddr <= CAM_BLOCK_SIZE;
            rSubStateChg <= 1'b1;
          end

          OBJ_VALID_TAG: begin
            rGlbState <= GLB_SET_OBJ;
            rOffsetAddr <= OBJ_BLOCK_SIZE;
            rSubStateChg <= 1'b1;
          end

          VRTX_VALID_TAG: begin
            rGlbState <= GLB_SET_OBJ_VTX;
            rSubStateChg <= 1'b1;
          end

          CLS_OBJ_VALID_TAG: begin
            rGlbState <= GLB_CLOSE_OBJ;
            rOffsetAddr <= CLS_OBJ_BLOCK_SIZE;
            rSubStateChg <= 1'b1;
            rOffsetVertex <= 1'b1;
          end

          TMATRIX_VALID_TAG: begin
            rGlbState <= GLB_CHG_TMATRIX;
            rOffsetAddr <= OBJ_BLOCK_SIZE;
            rTMatrixExcep <= 1'b1;
            rSubStateChg <= 1'b1;
          end

          REFRESH_VALID_TAG: begin
            rGlbState <= GLB_REFRESH;
            // TODO: Implementation
          end
          default: rGlbState <= GLB_WAIT_UART;

        endcase

      end // case GLB_WAIT_UART

      GLB_SET_INIT,
      GLB_SET_CAM,
      GLB_SET_OBJ,
      GLB_CLOSE_OBJ: begin
        rSubStateChg <= 1'b1;
      end // case GLB_SET_INIT, GLB_SET_CAM, GLB_SET_OBJ, GLB_CLOSE_OBJ

      GLB_SET_OBJ_VTX: begin
        if (rOffsetVertex) begin
          rOffsetAddr <= iRxByte;
          rOffsetVertex <= 1'b0;
        end else begin
          rSubStateChg <= 1'b1;
        end
      end // case GLB_SET_OBJ_VTX

      GLB_CHG_TMATRIX: begin
        rSubStateChg <= 1'b1;
      end // case GLB_CHG_TMATRIX

      GLB_REFRESH: begin
      end // case GLB_REFRESH

    endcase // rGlbState

  end // block rx_change


  //////////////////////
  // sub_states_manager:
  always @ (posedge rSubStateChg) begin
    case(rSubState)

      SUB_RESPONSE_TO_APPROVAL: begin
        oTxByte <= ~(iRxByte);
        rRespFinalState <= iRxByte;
        oTxReady <= 1'b1;
        rSubState <= SUB_SET_ADDRESS;
        rSubStateChg <= 1'b0;
      end // case SUB_RESPONSE_TO_APPROVAL

      SUB_SET_ADDRESS: begin
        rActualAddr <= iRxByte;
        rStopAddr <= iRxByte + rOffsetAddr;
        rSubState <= SUB_WRITING_IN_SRAM;
        rSubStateChg <= 1'b0;
      end // case SUB_SET_ADDRESS

      SUB_WRITING_IN_SRAM: begin
        if (rActualAddr == rStopAddr) begin

          if (!rTMatrixExcep) begin
            rData <= FINAL_BLOCK_VALID_TAG;
            oAddress <= rStopAddr;
            oWrite <= 1'b1;
            oValidRequest <= 1'b1;
            rSubState <= SUB_RESPONSE_TO_APPROVAL;
            rGlbState <= GLB_WAIT_UART;
          end else begin
            rTMatrixExcep <= 1'b0;
          end

          oTxByte <= rRespFinalState;
          oTxReady <= 1'b1;
          rSubStateChg <= 1'b0;
        end else begin
          rData <= iRxByte;
          oAddress <= rActualAddr;
          oWrite <= 1'b1;
          oValidRequest <= 1'b1;
          rActualAddr <= rActualAddr + 16'h0001;
          rSubStateChg <= 1'b0;
        end
      end // case SUB_WRITING_IN_SRAM

      default: begin
      end // case default

    endcase // rSubState

  end // block sub_states_manager

  /////////////////////////////////////////////////////////////////////////
  // uart_send_state: When UART is sending data this keep the Tx Ready HIGH
  //                  for at less one clock cycle
  always @ (posedge iClock) begin
    if (oTxReady) begin
      case (rUartSendState)

        UART_TO_SEND: rUartSendState <= UART_TO_CLOSE;

        UART_TO_CLOSE: begin
          oTxReady <= 1'b0;
          rUartSendState <= UART_TO_SEND;
        end // case UART_TO_CLOSE

        default: begin
          //** TODO: IDK if it's necessary
        end // case default

      endcase // rUartSendState
    end else begin
      //** TODO: IDK if it's necessary
    end // if-else oTxReady
  end // block uart_send_state

  ////////////////////
  // sram_set_request:
  always @ (posedge iValidRead) begin
    oValidRequest <= 0'b0;
  end // block sram_set_request

endmodule // men_ctrl
