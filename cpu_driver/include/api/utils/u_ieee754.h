#include <stdio.h>
#include <inttypes.h>

#define CHAR_BY_HALF_INDEX      2
#define HALF_PRECISION_EXPONENT 5
#define HALF_PRECISION_BIT      16
#define MAX_HALF_PRECISION      65504.0


/*********************************
  Convert half precision to string

INPUT   half_prec        is the half precision number
OUTPUT *half_prec_string is the string to be sent via UART
RETURN  0                if function was succesful
        errno            if function failed
*********************************/
int u_half_prec_to_string(uint16_t  half_prec,
                          char     *half_prec_string);


/*********************************************************
  Convert simple precision to half precision and to string

INPUT   simple_precision is the simple precision number
OUTPUT *half_prec        is the half precision number
OUTPUT *half_prec_string is the string to be sent via UART
RETURN  0                if function was succesful
        errno            if function failed
*********************************************************/
int u_float_to_half_prec(float     simple_precision,
                         uint16_t *half_prec,
                         char     *half_prec_string);


/**********************************************
  Convert to half precision to simple precision

INPUT   half_prec        is the half precision number
OUTPUT *simple_precision is the simple precision number
RETURN  0                if function was succesful
        errno            if function failed
**********************************************/
int u_half_prec_to_float(uint16_t  half_prec,
                         float    *simple_precision);
