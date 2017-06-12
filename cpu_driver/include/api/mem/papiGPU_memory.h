#include <stdio.h>

/**
 * Constant values of SRAM store format and communication tags
 */

#ifndef SRAM_ADDRESS_BYTE_SIZE
 #define SRAM_ADDRESS_BYTE_SIZE 2
 /**  */
#endif
#ifndef SRAM_ENTRY_BYTE_SIZE
 #define SRAM_ENTRY_BYTE_SIZE   2
 /**  */
#endif
#ifndef SRAM_TAG_BYTE_SIZE
 #define SRAM_TAG_BYTE_SIZE     2
 /**  */
#endif

#ifndef INITIAL_ADDRESS
  #define INITIAL_ADDRESS    0x0000
  /**  */
#endif
#ifndef NUMB_OBJS_ADDRESS
  #define NUMB_OBJS_ADDRESS  INITIAL_ADDRESS + 1
  /**  */
#endif
#ifndef INITIAL_BLOCK_SIZE
  #define INITIAL_BLOCK_SIZE 2
  /**  */
#endif

#ifndef CAM_ADDRESS
  #define CAM_ADDRESS    INITIAL_ADDRESS + INITIAL_BLOCK_SIZE
  /**  */
#endif
#ifndef CAM_BLOCK_SIZE
  #define CAM_BLOCK_SIZE 5
  /**  */
#endif

#ifndef INIT_OBJS_ADDRESS
  #define INIT_OBJS_ADDRESS CAM_ADDRESS + CAM_BLOCK_SIZE
  /**  */
#endif

#ifndef OBJ_SET_BLOCK_SIZE
  #define OBJ_SET_BLOCK_SIZE        2
  /**  */
#endif
#ifndef TMATRIX_BLOCK_SIZE
  #define TMATRIX_BLOCK_SIZE        12
  /**  */
#endif
#ifndef TO_INIT_VERTEX_BLOCK_SIZE
  #define TO_INIT_VERTEX_BLOCK_SIZE OBJ_SET_BLOCK_SIZE + TMATRIX_BLOCK_SIZE
  /**  */
#endif

#ifndef REQUEST_VALID_TAG
  #define REQUEST_VALID_TAG  0xAAAA
  /**  */
#endif
#ifndef APPROVAL_VALID_TAG
  #define APPROVAL_VALID_TAG 0x5555
  /**  */
#endif

#ifndef GPU_VALID_TAG
  #define GPU_VALID_TAG   0xCCCC //3333
  /**  */
#endif
#ifndef CAM_VALID_TAG
  #define CAM_VALID_TAG   0xBBBB //4444
  /**  */
#endif

#ifndef OBJ_VALID_TAG
  #define OBJ_VALID_TAG   0xEEEE
  /**  */
#endif
#ifndef OBJ_DISABLE_TAG
  #define OBJ_DISABLE_TAG ~(OBJ_VALID_TAG) /** 0x1111 */
  /**  */
#endif

#ifndef VRTX_VALID_TAG
  #define VRTX_VALID_TAG 0x9999 //6666
  /**  */
#endif

#ifndef CLS_OBJ_VALID_TAG
  #define CLS_OBJ_VALID_TAG 0x8888 //7777
  /**  */
#endif

#ifndef TMATRIX_VALID_TAG
  #define TMATRIX_VALID_TAG 0xABCD // 5432
  /** */
#endif

#ifndef REFRESH_VALID_TAG
  #define REFRESH_VALID_TAG 0x1234 // EDCB
  /** */
#endif

#ifndef FINAL_BLOCK_VALID_TAG
  #define FINAL_BLOCK_VALID_TAG 0xFFFF
  /** */
#endif

#ifndef ERROR_TAG
  #define ERROR_TAG 0x1414
  /** */
#endif

#ifndef BUSY_TAG
  #define BUSY_TAG 0x4141
  /** */
#endif
