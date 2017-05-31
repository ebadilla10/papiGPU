`timescale 1ns / 1ps

module mem_ctrl(
  // Inputs
  input wire iClock,
  input wire iReset,

  // Outputs to Graphics Pipeline
  output reg        oEnable,
  output wire       oInitObj,
  output wire       oInitVtx,
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
  input wire       iTxSent,
  // Output to UART
  output reg [7:0] oTxByte,
  output reg       oTxReady
);

  // Memory control sizes
  parameter GLB_STATE_SIZE       = 3;
  parameter UART_SEND_STATE_SIZE = 1;
  parameter SUB_STATE_SIZE       = 2;
  parameter VIA_UART_STATE_SIZE  = 2;
  parameter REFRESH_STATE_SIZE   = 5;
  parameter RFRSH_INIT_GPU_SUBSTATE_SIZE = 1;
  parameter RFRSH_OBJ_SUBSTATE_SIZE = 1;

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
  parameter BUSY_TAG              = 16'h4141;


  // UART Receiver States
  parameter UART_FIRST_BYTE = 1'b0;
  parameter UART_SECOND_BYTE = 1'b1;

  // UART Receiver States
  parameter UART_FIRST_BYTE_S = 1'b0;
  parameter UART_SECOND_BYTE_S = 1'b1;

  // Refresh States
  parameter REFRESH_CAM_VER_X = 5'b00000;
  parameter REFRESH_CAM_VER_Y = 5'b00001;
  parameter REFRESH_CAM_VER_Z = 5'b00010;
  parameter REFRESH_CAM_DC    = 5'b00011;
  parameter REFRESH_COS_ROLL  = 5'b00100;
  parameter REFRESH_COS_PITCH = 5'b00101;
  parameter REFRESH_COS_YAW   = 5'b00110;
  parameter REFRESH_SEN_ROLL  = 5'b00111;
  parameter REFRESH_SEN_PITCH = 5'b01000;
  parameter REFRESH_SEN_YAW   = 5'b01001;
  parameter REFRESH_SCALE_X   = 5'b01010;
  parameter REFRESH_SCALE_Y   = 5'b01011;
  parameter REFRESH_SCALE_Z   = 5'b01100;
  parameter REFRESH_TRANSL_X  = 5'b01101;
  parameter REFRESH_TRANSL_Y  = 5'b01110;
  parameter REFRESH_TRANSL_Z  = 5'b01111;
  parameter REFRESH_VERTEX_X  = 5'b10000;
  parameter REFRESH_VERTEX_Y  = 5'b10001;
  parameter REFRESH_VERTEX_Z  = 5'b10010;

  parameter REFRESH_INIT_GPU  = 5'b10011;
  parameter REFRESH_INIT_CAM  = 5'b10100;
  parameter REFRESH_INIT_OBJ  = 5'b10101;
  parameter REFRESH_INIT_VTX  = 5'b10110;

  // Refresh Init GPU Substates
  parameter RFRSH_INT_GPU_VALID_TAG = 1'b0;
  parameter RFRSH_INT_GPU_NUM_OBJ   = 1'b1;

  // Refresh Object Substates
  parameter RFRSH_OBJ_VALID_TAG = 1'b0;
  parameter RFRSH_OBJ_NEXT_ADDR = 1'b1;

  // State registers
  reg [GLB_STATE_SIZE-1:0]       rGlbState      = GLB_WAIT_UART;
  reg [UART_SEND_STATE_SIZE-1:0] rUartSendState = UART_TO_SEND;
  reg [SUB_STATE_SIZE-1:0]       rSubState      = SUB_RESPONSE_TO_APPROVAL;
  reg                            rSubStateChg   = 1'b0;
  reg [REFRESH_STATE_SIZE-1:0]   rRefreshState  = REFRESH_INIT_GPU;
  reg [RFRSH_INIT_GPU_SUBSTATE_SIZE-1:0] rRfrshInitGpuSubState = RFRSH_INT_GPU_VALID_TAG;
  reg [RFRSH_OBJ_SUBSTATE_SIZE-1:0] rRfrshObjSubState = RFRSH_OBJ_VALID_TAG;

  // SRAM registers
  reg [15:0] rActualAddr = 16'h0000;
  reg [15:0] rStopAddr   = 16'h0000;
  reg [15:0] rOffsetAddr = 16'h0000;

  reg [15:0] rData           = 16'h0000;
  reg [15:0] rRespFinalState = 16'h0000;
  reg        rOffsetVertex   = 1'b0;
  reg        rTMatrixExcep   = 1'b0;

  assign ioData = (!oWrite) ? 16'bz : rData;

  // Collect data via UART registers
  reg        iRx16BitsReady;
  reg [15:0] iRx16Bits;

  reg        iTx16BitsReady;
  reg [15:0] iTx16Bits;

  reg [VIA_UART_STATE_SIZE-1:0] uart_receive_state = UART_FIRST_BYTE;
  reg [VIA_UART_STATE_SIZE-1:0] uart_transmit_state = UART_FIRST_BYTE;

  // Refresh state registers
  reg rInitRefresh = 1'b0;
  reg rBusyGPU = 1'b0;

  // Register
  reg [15:0] rNumObjts = 16'h0000;
  reg [15:0] rContNumObjts = 16'h0000;
  reg        rInvalidObj     = 1'b0;

  reg [15:0] rNextObjAddr = 16'h0000;

  ///////////////////////////////////////////////////////////////
  // uart_receiver: Collects data sent via UART in 16-bits blocks
  always @ (posedge iRxReady) begin

    case (uart_receive_state)

      UART_FIRST_BYTE: begin
        iRx16Bits [15:8] <= iRxByte;
        iRx16BitsReady <= 1'b0;
        uart_receive_state <= UART_SECOND_BYTE;
      end // case UART_FIRST_BYTE

      UART_SECOND_BYTE: begin
        iRx16Bits [7:0] <= iRxByte;
        iRx16BitsReady <= 1'b1;
        uart_receive_state <= UART_FIRST_BYTE;
      end // case UART_SECOND_BYTE_R
    endcase

  end // block uart_receiver

  ////////////////////////////////////////////////////////////////////
  // uart_transmitter: Collect 16-bits data blocks to be sent via UART
  always @ (posedge iTx16BitsReady) begin

    if (uart_transmit_state == UART_FIRST_BYTE) begin
      oTxByte <= iTx16Bits[15:8];
      oTxReady <= 1'b1;
      uart_transmit_state <= UART_SECOND_BYTE;
    end else begin
    end

  end // block uart_transmitter

  always @ (posedge iTxSent) begin

    if (uart_transmit_state == UART_SECOND_BYTE) begin
      oTxByte <= iTx16Bits[7:0];
      oTxReady <= 1'b1;
      uart_transmit_state <= UART_FIRST_BYTE;
    end

  end

  /////////////////////////////////////////////////////////////////
  // rx_change: If data is received via UART this manage the Memory
  //            Control States
  always @ (posedge iRx16BitsReady) begin
    case(rGlbState)

      GLB_WAIT_UART: begin
        case(iRx16Bits)

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
            rSubStateChg <= 1'b1;
            rInitRefresh <= 1'b1;
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
          rOffsetAddr <= iRx16Bits;
          rOffsetVertex <= 1'b0;
        end else begin
          rSubStateChg <= 1'b1;
        end
      end // case GLB_SET_OBJ_VTX

      GLB_CHG_TMATRIX: begin
        rSubStateChg <= 1'b1;
      end // case GLB_CHG_TMATRIX

      GLB_REFRESH: begin
        rBusyGPU <= 1'b1;
      end // case GLB_REFRESH

    endcase // rGlbState

  end // block rx_change

  //////////////////////
  // sub_states_manager:
  always @ (posedge rSubStateChg) begin
    case(rSubState)

      SUB_RESPONSE_TO_APPROVAL: begin
        iTx16Bits <= ~(iRx16Bits);
        rRespFinalState <= iRx16Bits;
        iTx16BitsReady <= 1'b1;
        rSubState <= SUB_SET_ADDRESS;
        rSubStateChg <= 1'b0;
      end // case SUB_RESPONSE_TO_APPROVAL

      SUB_SET_ADDRESS: begin
        rActualAddr <= iRx16Bits;
        rStopAddr <= iRx16Bits + rOffsetAddr;
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

          iTx16Bits <= rRespFinalState;
          iTx16BitsReady <= 1'b1;
          rSubStateChg <= 1'b0;
        end else begin
          rData <= iRx16Bits;
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

  //////////////////////
  // refresh_controller:
  always @ ( posedge rInitRefresh) begin

    oAddress <= INITIAL_ADDRESS;
    oWrite <= 1'b0;
    oValidRequest <= 1'b1;

  end // block refresh_controller

  always @ ( posedge iValidRead ) begin

    if (rInitRefresh) begin

      case(rRefreshState)

        REFRESH_INIT_GPU: begin

          case (rRfrshInitGpuSubState)
            RFRSH_INT_GPU_VALID_TAG: begin
              case (ioData)
                GPU_VALID_TAG: begin
                  rRfrshInitGpuSubState <= RFRSH_INT_GPU_NUM_OBJ;
                  oAddress <= oAddress + 1;
                  oWrite <= 1'b0;
                  oValidRequest <= 1'b1;
                end // case GPU_VALID_TAG

                ~GPU_VALID_TAG: begin
                end // case ~GPU_VALID_TAG

                default: begin
                end // case default

              endcase // ioData
            end // case RFRSH_INT_GPU_VALID_TAG

            RFRSH_INT_GPU_NUM_OBJ: begin
              rNumObjts <= ioData;
              oAddress <= oAddress + 1;
              oWrite <= 1'b0;
              oValidRequest <= 1'b1;
              rRfrshInitGpuSubState <= RFRSH_INT_GPU_VALID_TAG;
              rRefreshState <= REFRESH_INIT_CAM;
            end // case RFRSH_INT_GPU_NUM_OBJ

            default: begin
            end // case default

          endcase // rRfrshInitGpuSubState

        end // case REFRESH_INIT_GPU

        REFRESH_INIT_CAM: begin
          if (ioData == CAM_VALID_TAG) begin
            oAddress <= oAddress + 1;
            oWrite <= 1'b0;
            oValidRequest <= 1'b1;
            rRefreshState <= REFRESH_CAM_VER_X;
          end else begin

          end
        end // case REFRESH_INIT_CAM

        REFRESH_CAM_VER_X: begin
          oCamVerX <= ioData;
          oAddress <= oAddress + 1;
          oWrite <= 1'b0;
          oValidRequest <= 1'b1;
          rRefreshState <= REFRESH_CAM_VER_Y;
        end // case REFRESH_CAM_VER_X

        REFRESH_CAM_VER_Y: begin
          oCamVerY <= ioData;
          oAddress <= oAddress + 1;
          oWrite <= 1'b0;
          oValidRequest <= 1'b1;
          rRefreshState <= REFRESH_CAM_VER_Z;
        end // case REFRESH_CAM_VER_Y

        REFRESH_CAM_VER_Z: begin
          oCamVerZ <= ioData;
          oAddress <= oAddress + 1;
          oWrite <= 1'b0;
          oValidRequest <= 1'b1;
          rRefreshState <= REFRESH_CAM_DC;
        end // case REFRESH_CAM_VER_Z

        REFRESH_CAM_DC: begin
          oCamDc <= ioData;
          oAddress <= oAddress + 1;
          oWrite <= 1'b0;
          oValidRequest <= 1'b1;
          rRefreshState <= REFRESH_INIT_OBJ;
        end // case REFRESH_CAM_DC

        REFRESH_INIT_OBJ: begin
          case (rRfrshObjSubState)
            RFRSH_OBJ_VALID_TAG: begin
              case (ioData)
                OBJ_VALID_TAG: begin
                  oAddress <= oAddress + 1;
                  oWrite <= 1'b0;
                  oValidRequest <= 1'b1;
                  rRfrshObjSubState <= RFRSH_OBJ_NEXT_ADDR;
                end // case OBJ_VALID_TAG

                ~OBJ_VALID_TAG: begin
                  rInvalidObj = 1'b1;
                  oAddress <= oAddress + 1;
                  oWrite <= 1'b0;
                  oValidRequest <= 1'b1;
                  rRfrshObjSubState <= RFRSH_OBJ_NEXT_ADDR;
                end // case ~OBJ_VALID_TAG
              endcase // ioData
            end // case RFRSH_OBJ_VALID_TAG

            RFRSH_OBJ_NEXT_ADDR: begin
              if (rInvalidObj) begin
                oAddress <= ioData;
                oWrite <= 1'b0;
                oValidRequest <= 1'b1;
                rRfrshObjSubState <= RFRSH_OBJ_VALID_TAG;
                rInvalidObj = 1'b0;
              end else begin
                rNextObjAddr <= ioData;
                oAddress <= oAddress + 1;
                oWrite <= 1'b0;
                oValidRequest <= 1'b1;
                rRfrshObjSubState <= RFRSH_OBJ_VALID_TAG;
                rRefreshState <= REFRESH_COS_ROLL;
              end
            end // case RFRSH_OBJ_NEXT_ADDR

            default: begin
            end // case default

          endcase // rRfrshObjSubState
        end // case REFRESH_INIT_OBJ

        REFRESH_COS_ROLL: begin
          oCosRoll <= ioData;
          oAddress <= oAddress + 1;
          oWrite <= 1'b0;
          oValidRequest <= 1'b1;
          rRefreshState <= REFRESH_COS_PITCH;

        end // case REFRESH_COS_ROLL

      endcase // rRefreshState

    end // if rInitRefresh

  end

  //////////////////////////////////////////////////////
  // busy_gpu: Return the Busy Tag to CPU if GPU is busy
  always @ (posedge rBusyGPU) begin
    iTx16Bits <= BUSY_TAG;
    iTx16BitsReady <= 1'b1;
    rBusyGPU <= 0'b0;
  end // block busy_gpu

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
