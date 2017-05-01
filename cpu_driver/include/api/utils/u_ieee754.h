#include <stdio.h>
#include <inttypes.h>

#define CHAR_BY_HALF_INDEX      2
#define HALF_PRECISION_EXPONENT 5
#define HALF_PRECISION_BIT      16
#define MAX_HALF_PRECISION      65504.0

int u_half_prec_to_string(uint16_t  half_prec,
                          char     *half_prec_string);

int u_float_to_half_prec(float     simple_precision,
                         uint16_t *half_prec,
                         char     *half_prec_string);

int u_half_prec_to_float(uint16_t  half_prec,
                         float    *simple_precision);
