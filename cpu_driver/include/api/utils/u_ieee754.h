#include <stdio.h>
#include <inttypes.h>

#ifndef CHAR_BY_HALF_INDEX
  #define CHAR_BY_HALF_INDEX      2
  /**  */
#endif
#ifndef HALF_PRECISION_EXPONENT
  #define HALF_PRECISION_EXPONENT 5
  /**  */
#endif
#ifndef HALF_PRECISION_BIT
  #define HALF_PRECISION_BIT      16
  /**  */
#endif
#ifndef MAX_HALF_PRECISION
  #define MAX_HALF_PRECISION      65504.0
  /**  */
#endif


/**
 * Convert half precision to string
 *
 * @param[in]   half_prec        is the half precision number
 * @param[out] *half_prec_string is the string to be sent via UART
 * @return      0                if function was succesful
 *              errno            if function failed
 */
int u_half_prec_to_string(uint16_t  half_prec,
                          char     *half_prec_string);


/**
 * Convert simple precision to half precision and to string
 *
 * @param[in]   simple_precision is the simple precision number
 * @param[out] *half_prec        is the half precision number
 * @param[out] *half_prec_string is the string to be sent via UART
 * @return      0                if function was succesful
 *              errno            if function failed
 */
int u_float_to_half_prec(float     simple_precision,
                         uint16_t *half_prec,
                         char     *half_prec_string);


/**
 * Convert to half precision to simple precision
 *
 * @param[in]   half_prec        is the half precision number
 * @param[out] *simple_precision is the simple precision number
 * @return      0                if function was succesful
 *              errno            if function failed
 */
int u_half_prec_to_float(uint16_t  half_prec,
                         float    *simple_precision);
