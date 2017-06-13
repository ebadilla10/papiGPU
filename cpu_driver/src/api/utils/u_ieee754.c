#include <stdio.h>
#include <api/utils/u_ieee754.h>
#include <inttypes.h>
#include <errno.h>
#include <string.h>

#define BYTESIZE 8


/**
 * Convert half precision to string
 */
int u_half_prec_to_string(uint16_t  half_prec,
                          char     *half_prec_string)
{
  uint16_t rotate = (half_prec << BYTESIZE) | (half_prec >> BYTESIZE);
  memcpy(half_prec_string, (char*)(&rotate), sizeof(uint16_t));
  return 0; // NO errors
}


/**
 * Convert simple precision to half precision and to string
 */
int u_float_to_half_prec(float     simple_precision,
                         uint16_t *half_prec,
                         char     *half_prec_string)
{
  // Check the max valid valid of simple precision
  if (simple_precision > MAX_HALF_PRECISION) {
    fprintf (stderr, "ERROR: The simple precision value is greater " \
             "than %.2f\n", MAX_HALF_PRECISION);
    return EINVAL;
  }

  // Variables
  float fnorm;
  int   shift;
  long  sign, exp, significand;

  uint32_t significandbits = HALF_PRECISION_BIT - HALF_PRECISION_EXPONENT - 1;

  // Special case
  if (0.0 == simple_precision) {
    *half_prec = 0;
    u_half_prec_to_string(*half_prec, half_prec_string);
    return 0;
  }

  // Check sign and normalize
  if (simple_precision < 0) {
    sign = 1;
    fnorm = -simple_precision;
  }
  else {
    sign = 0;
    fnorm = simple_precision;
  }

  // Get the normalized value and track the exponent
  shift = 0;
  while(fnorm >= 2.0) {
    fnorm /= 2.0; shift++;
  }
  while(fnorm < 1.0) {
    fnorm *= 2.0; shift--;
  }
  fnorm = fnorm - 1.0;

  // Calculate the binary values of the significand data
  significand = fnorm * ((1l << significandbits) + 0.5f);

  // Get the BIAS exponent
  exp = shift + ((1 << (HALF_PRECISION_EXPONENT - 1)) - 1);

  // Return the Half Precision value (uint16 and ASCII-string Mode)
  *half_prec = (sign << (HALF_PRECISION_BIT - 1)) | \
               (exp << (HALF_PRECISION_BIT - HALF_PRECISION_EXPONENT - 1)) \
               | significand;
  u_half_prec_to_string(*half_prec, half_prec_string);

  return 0; // NO errors
}


/**
 * Convert to half precision to simple precision
 */
int u_half_prec_to_float(uint16_t  half_prec,
                         float    *simple_precision)
{
  // Variables
  long     shift;
  uint32_t bias;
  uint32_t significandbits = HALF_PRECISION_BIT - HALF_PRECISION_EXPONENT - 1;

  // Special case
  if (half_prec == 0) {
    *simple_precision = 0.0;
    return 0; // NO errors
  }

  // Pull the significand
  *simple_precision = (half_prec & ((1l << significandbits) - 1));
  *simple_precision /= (1l << significandbits);
  *simple_precision += 1.0f;

  // Obtain exponent
  bias = (1 << (HALF_PRECISION_EXPONENT - 1)) - 1;
  shift = ((half_prec >> significandbits) & \
          ((1l << HALF_PRECISION_EXPONENT) - 1)) - bias;
  while(shift > 0) {
    *simple_precision *= 2.0;
    shift--;
  }
  while(shift < 0) {
    *simple_precision /= 2.0;
    shift++;
  }

  // Return the simple precision value (float)
  *simple_precision *= (half_prec >> (HALF_PRECISION_BIT - 1)) & 1? -1.0: 1.0;

  return 0; // NO errors
}
