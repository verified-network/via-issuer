// File: contracts/abdk-libraries-solidity/ABDKMathQuad.sol

// SPDX-License-Identifier: BSD-4-Clause
/*
 * ABDK Math Quad Smart Contract Library.  Copyright © 2019 by ABDK Consulting.
 * Author: Mikhail Vladimirov <mikhail.vladimirov@gmail.com>
 */
pragma solidity >=0.5.0 <=0.7.0;

/**
 * Smart contract library of mathematical functions operating with IEEE 754
 * quadruple-precision binary floating-point numbers (quadruple precision
 * numbers).  As long as quadruple precision numbers are 16-bytes long, they are
 * represented by bytes16 type.
 */
library ABDKMathQuad {
  /*
   * 0.
   */
  bytes16 private constant POSITIVE_ZERO = 0x00000000000000000000000000000000;

  /*
   * -0.
   */
  bytes16 private constant NEGATIVE_ZERO = 0x80000000000000000000000000000000;

  /*
   * +Infinity.
   */
  bytes16 private constant POSITIVE_INFINITY = 0x7FFF0000000000000000000000000000;

  /*
   * -Infinity.
   */
  bytes16 private constant NEGATIVE_INFINITY = 0xFFFF0000000000000000000000000000;

  /*
   * Canonical NaN value.
   */
  bytes16 private constant NaN = 0x7FFF8000000000000000000000000000;

  /**
   * Convert signed 256-bit integer number into quadruple precision number.
   *
   * @param x signed 256-bit integer number
   * @return quadruple precision number
   */
  function fromInt (int256 x) internal pure returns (bytes16) {
    if (x == 0) return bytes16 (0);
    else {
      // We rely on overflow behavior here
      uint256 result = uint256 (x > 0 ? x : -x);

      uint256 msb = msb (result);
      if (msb < 112) result <<= 112 - msb;
      else if (msb > 112) result >>= msb - 112;

      result = result & 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFF | 16383 + msb << 112;
      if (x < 0) result |= 0x80000000000000000000000000000000;

      return bytes16 (uint128 (result));
    }
  }

  /**
   * Convert quadruple precision number into signed 256-bit integer number
   * rounding towards zero.  Revert on overflow.
   *
   * @param x quadruple precision number
   * @return signed 256-bit integer number
   */
  function toInt (bytes16 x) internal pure returns (int256) {
    uint256 exponent = uint128 (x) >> 112 & 0x7FFF;

    require (exponent <= 16638); // Overflow
    if (exponent < 16383) return 0; // Underflow

    uint256 result = uint256 (uint128 (x)) & 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFF |
      0x10000000000000000000000000000;

    if (exponent < 16495) result >>= 16495 - exponent;
    else if (exponent > 16495) result <<= exponent - 16495;

    if (uint128 (x) >= 0x80000000000000000000000000000000) { // Negative
      require (result <= 0x8000000000000000000000000000000000000000000000000000000000000000);
      return -int256 (result); // We rely on overflow behavior here
    } else {
      require (result <= 0x7FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF);
      return int256 (result);
    }
  }

  /**
   * Convert unsigned 256-bit integer number into quadruple precision number.
   *
   * @param x unsigned 256-bit integer number
   * @return quadruple precision number
   */
  function fromUInt (uint256 x) internal pure returns (bytes16) {
    if (x == 0) return bytes16 (0);
    else {
      uint256 result = x;

      uint256 msb = msb (result);
      if (msb < 112) result <<= 112 - msb;
      else if (msb > 112) result >>= msb - 112;

      result = result & 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFF | 16383 + msb << 112;

      return bytes16 (uint128 (result));
    }
  }

  /**
   * Convert quadruple precision number into unsigned 256-bit integer number
   * rounding towards zero.  Revert on underflow.  Note, that negative floating
   * point numbers in range (-1.0 .. 0.0) may be converted to unsigned integer
   * without error, because they are rounded to zero.
   *
   * @param x quadruple precision number
   * @return unsigned 256-bit integer number
   */
  function toUInt (bytes16 x) internal pure returns (uint256) {
    uint256 exponent = uint128 (x) >> 112 & 0x7FFF;

    if (exponent < 16383) return 0; // Underflow

    require (uint128 (x) < 0x80000000000000000000000000000000); // Negative

    require (exponent <= 16638); // Overflow
    uint256 result = uint256 (uint128 (x)) & 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFF |
      0x10000000000000000000000000000;

    if (exponent < 16495) result >>= 16495 - exponent;
    else if (exponent > 16495) result <<= exponent - 16495;

    return result;
  }

  /**
   * Convert signed 128.128 bit fixed point number into quadruple precision
   * number.
   *
   * @param x signed 128.128 bit fixed point number
   * @return quadruple precision number
   */
  function from128x128 (int256 x) internal pure returns (bytes16) {
    if (x == 0) return bytes16 (0);
    else {
      // We rely on overflow behavior here
      uint256 result = uint256 (x > 0 ? x : -x);

      uint256 msb = msb (result);
      if (msb < 112) result <<= 112 - msb;
      else if (msb > 112) result >>= msb - 112;

      result = result & 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFF | 16255 + msb << 112;
      if (x < 0) result |= 0x80000000000000000000000000000000;

      return bytes16 (uint128 (result));
    }
  }

  /**
   * Convert quadruple precision number into signed 128.128 bit fixed point
   * number.  Revert on overflow.
   *
   * @param x quadruple precision number
   * @return signed 128.128 bit fixed point number
   */
  function to128x128 (bytes16 x) internal pure returns (int256) {
    uint256 exponent = uint128 (x) >> 112 & 0x7FFF;

    require (exponent <= 16510); // Overflow
    if (exponent < 16255) return 0; // Underflow

    uint256 result = uint256 (uint128 (x)) & 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFF |
      0x10000000000000000000000000000;

    if (exponent < 16367) result >>= 16367 - exponent;
    else if (exponent > 16367) result <<= exponent - 16367;

    if (uint128 (x) >= 0x80000000000000000000000000000000) { // Negative
      require (result <= 0x8000000000000000000000000000000000000000000000000000000000000000);
      return -int256 (result); // We rely on overflow behavior here
    } else {
      require (result <= 0x7FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF);
      return int256 (result);
    }
  }

  /**
   * Convert signed 64.64 bit fixed point number into quadruple precision
   * number.
   *
   * @param x signed 64.64 bit fixed point number
   * @return quadruple precision number
   */
  function from64x64 (int128 x) internal pure returns (bytes16) {
    if (x == 0) return bytes16 (0);
    else {
      // We rely on overflow behavior here
      uint256 result = uint128 (x > 0 ? x : -x);

      uint256 msb = msb (result);
      if (msb < 112) result <<= 112 - msb;
      else if (msb > 112) result >>= msb - 112;

      result = result & 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFF | 16319 + msb << 112;
      if (x < 0) result |= 0x80000000000000000000000000000000;

      return bytes16 (uint128 (result));
    }
  }

  /**
   * Convert quadruple precision number into signed 64.64 bit fixed point
   * number.  Revert on overflow.
   *
   * @param x quadruple precision number
   * @return signed 64.64 bit fixed point number
   */
  function to64x64 (bytes16 x) internal pure returns (int128) {
    uint256 exponent = uint128 (x) >> 112 & 0x7FFF;

    require (exponent <= 16446); // Overflow
    if (exponent < 16319) return 0; // Underflow

    uint256 result = uint256 (uint128 (x)) & 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFF |
      0x10000000000000000000000000000;

    if (exponent < 16431) result >>= 16431 - exponent;
    else if (exponent > 16431) result <<= exponent - 16431;

    if (uint128 (x) >= 0x80000000000000000000000000000000) { // Negative
      require (result <= 0x80000000000000000000000000000000);
      return -int128 (result); // We rely on overflow behavior here
    } else {
      require (result <= 0x7FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF);
      return int128 (result);
    }
  }

  /**
   * Convert octuple precision number into quadruple precision number.
   *
   * @param x octuple precision number
   * @return quadruple precision number
   */
  function fromOctuple (bytes32 x) internal pure returns (bytes16) {
    bool negative = x & 0x8000000000000000000000000000000000000000000000000000000000000000 > 0;

    uint256 exponent = uint256 (x) >> 236 & 0x7FFFF;
    uint256 significand = uint256 (x) & 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF;

    if (exponent == 0x7FFFF) {
      if (significand > 0) return NaN;
      else return negative ? NEGATIVE_INFINITY : POSITIVE_INFINITY;
    }

    if (exponent > 278526)
      return negative ? NEGATIVE_INFINITY : POSITIVE_INFINITY;
    else if (exponent < 245649)
      return negative ? NEGATIVE_ZERO : POSITIVE_ZERO;
    else if (exponent < 245761) {
      significand = (significand | 0x100000000000000000000000000000000000000000000000000000000000) >> 245885 - exponent;
      exponent = 0;
    } else {
      significand >>= 124;
      exponent -= 245760;
    }

    uint128 result = uint128 (significand | exponent << 112);
    if (negative) result |= 0x80000000000000000000000000000000;

    return bytes16 (result);
  }

  /**
   * Convert quadruple precision number into octuple precision number.
   *
   * @param x quadruple precision number
   * @return octuple precision number
   */
  function toOctuple (bytes16 x) internal pure returns (bytes32) {
    uint256 exponent = uint128 (x) >> 112 & 0x7FFF;

    uint256 result = uint128 (x) & 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFF;

    if (exponent == 0x7FFF) exponent = 0x7FFFF; // Infinity or NaN
    else if (exponent == 0) {
      if (result > 0) {
        uint256 msb = msb (result);
        result = result << 236 - msb & 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF;
        exponent = 245649 + msb;
      }
    } else {
      result <<= 124;
      exponent += 245760;
    }

    result |= exponent << 236;
    if (uint128 (x) >= 0x80000000000000000000000000000000)
      result |= 0x8000000000000000000000000000000000000000000000000000000000000000;

    return bytes32 (result);
  }

  /**
   * Convert double precision number into quadruple precision number.
   *
   * @param x double precision number
   * @return quadruple precision number
   */
  function fromDouble (bytes8 x) internal pure returns (bytes16) {
    uint256 exponent = uint64 (x) >> 52 & 0x7FF;

    uint256 result = uint64 (x) & 0xFFFFFFFFFFFFF;

    if (exponent == 0x7FF) exponent = 0x7FFF; // Infinity or NaN
    else if (exponent == 0) {
      if (result > 0) {
        uint256 msb = msb (result);
        result = result << 112 - msb & 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFF;
        exponent = 15309 + msb;
      }
    } else {
      result <<= 60;
      exponent += 15360;
    }

    result |= exponent << 112;
    if (x & 0x8000000000000000 > 0)
      result |= 0x80000000000000000000000000000000;

    return bytes16 (uint128 (result));
  }

  /**
   * Convert quadruple precision number into double precision number.
   *
   * @param x quadruple precision number
   * @return double precision number
   */
  function toDouble (bytes16 x) internal pure returns (bytes8) {
    bool negative = uint128 (x) >= 0x80000000000000000000000000000000;

    uint256 exponent = uint128 (x) >> 112 & 0x7FFF;
    uint256 significand = uint128 (x) & 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFF;

    if (exponent == 0x7FFF) {
      if (significand > 0) return 0x7FF8000000000000; // NaN
      else return negative ?
          bytes8 (0xFFF0000000000000) : // -Infinity
          bytes8 (0x7FF0000000000000); // Infinity
    }

    if (exponent > 17406)
      return negative ?
          bytes8 (0xFFF0000000000000) : // -Infinity
          bytes8 (0x7FF0000000000000); // Infinity
    else if (exponent < 15309)
      return negative ?
          bytes8 (0x8000000000000000) : // -0
          bytes8 (0x0000000000000000); // 0
    else if (exponent < 15361) {
      significand = (significand | 0x10000000000000000000000000000) >> 15421 - exponent;
      exponent = 0;
    } else {
      significand >>= 60;
      exponent -= 15360;
    }

    uint64 result = uint64 (significand | exponent << 52);
    if (negative) result |= 0x8000000000000000;

    return bytes8 (result);
  }

  /**
   * Test whether given quadruple precision number is NaN.
   *
   * @param x quadruple precision number
   * @return true if x is NaN, false otherwise
   */
  function isNaN (bytes16 x) internal pure returns (bool) {
    return uint128 (x) & 0x7FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF >
      0x7FFF0000000000000000000000000000;
  }

  /**
   * Test whether given quadruple precision number is positive or negative
   * infinity.
   *
   * @param x quadruple precision number
   * @return true if x is positive or negative infinity, false otherwise
   */
  function isInfinity (bytes16 x) internal pure returns (bool) {
    return uint128 (x) & 0x7FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF ==
      0x7FFF0000000000000000000000000000;
  }

  /**
   * Calculate sign of x, i.e. -1 if x is negative, 0 if x if zero, and 1 if x
   * is positive.  Note that sign (-0) is zero.  Revert if x is NaN. 
   *
   * @param x quadruple precision number
   * @return sign of x
   */
  function sign (bytes16 x) internal pure returns (int8) {
    uint128 absoluteX = uint128 (x) & 0x7FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF;

    require (absoluteX <= 0x7FFF0000000000000000000000000000); // Not NaN

    if (absoluteX == 0) return 0;
    else if (uint128 (x) >= 0x80000000000000000000000000000000) return -1;
    else return 1;
  }

  /**
   * Calculate sign (x - y).  Revert if either argument is NaN, or both
   * arguments are infinities of the same sign. 
   *
   * @param x quadruple precision number
   * @param y quadruple precision number
   * @return sign (x - y)
   */
  function cmp (bytes16 x, bytes16 y) internal pure returns (int8) {
    uint128 absoluteX = uint128 (x) & 0x7FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF;

    require (absoluteX <= 0x7FFF0000000000000000000000000000); // Not NaN

    uint128 absoluteY = uint128 (y) & 0x7FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF;

    require (absoluteY <= 0x7FFF0000000000000000000000000000); // Not NaN

    // Not infinities of the same sign
    require (x != y || absoluteX < 0x7FFF0000000000000000000000000000);

    if (x == y) return 0;
    else {
      bool negativeX = uint128 (x) >= 0x80000000000000000000000000000000;
      bool negativeY = uint128 (y) >= 0x80000000000000000000000000000000;

      if (negativeX) {
        if (negativeY) return absoluteX > absoluteY ? -1 : int8 (1);
        else return -1; 
      } else {
        if (negativeY) return 1;
        else return absoluteX > absoluteY ? int8 (1) : -1;
      }
    }
  }

  /**
   * Test whether x equals y.  NaN, infinity, and -infinity are not equal to
   * anything. 
   *
   * @param x quadruple precision number
   * @param y quadruple precision number
   * @return true if x equals to y, false otherwise
   */
  function eq (bytes16 x, bytes16 y) internal pure returns (bool) {
    if (x == y) {
      return uint128 (x) & 0x7FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF <
        0x7FFF0000000000000000000000000000;
    } else return false;
  }

  /**
   * Calculate x + y.  Special values behave in the following way:
   *
   * NaN + x = NaN for any x.
   * Infinity + x = Infinity for any finite x.
   * -Infinity + x = -Infinity for any finite x.
   * Infinity + Infinity = Infinity.
   * -Infinity + -Infinity = -Infinity.
   * Infinity + -Infinity = -Infinity + Infinity = NaN.
   *
   * @param x quadruple precision number
   * @param y quadruple precision number
   * @return quadruple precision number
   */
  function add (bytes16 x, bytes16 y) internal pure returns (bytes16) {
    uint256 xExponent = uint128 (x) >> 112 & 0x7FFF;
    uint256 yExponent = uint128 (y) >> 112 & 0x7FFF;

    if (xExponent == 0x7FFF) {
      if (yExponent == 0x7FFF) { 
        if (x == y) return x;
        else return NaN;
      } else return x; 
    } else if (yExponent == 0x7FFF) return y;
    else {
      bool xSign = uint128 (x) >= 0x80000000000000000000000000000000;
      uint256 xSignifier = uint128 (x) & 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFF;
      if (xExponent == 0) xExponent = 1;
      else xSignifier |= 0x10000000000000000000000000000;

      bool ySign = uint128 (y) >= 0x80000000000000000000000000000000;
      uint256 ySignifier = uint128 (y) & 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFF;
      if (yExponent == 0) yExponent = 1;
      else ySignifier |= 0x10000000000000000000000000000;

      if (xSignifier == 0) return y == NEGATIVE_ZERO ? POSITIVE_ZERO : y;
      else if (ySignifier == 0) return x == NEGATIVE_ZERO ? POSITIVE_ZERO : x;
      else {
        int256 delta = int256 (xExponent) - int256 (yExponent);
  
        if (xSign == ySign) {
          if (delta > 112) return x;
          else if (delta > 0) ySignifier >>= uint256 (delta);
          else if (delta < -112) return y;
          else if (delta < 0) {
            xSignifier >>= uint256 (-delta);
            xExponent = yExponent;
          }
  
          xSignifier += ySignifier;
  
          if (xSignifier >= 0x20000000000000000000000000000) {
            xSignifier >>= 1;
            xExponent += 1;
          }
  
          if (xExponent == 0x7FFF)
            return xSign ? NEGATIVE_INFINITY : POSITIVE_INFINITY;
          else {
            if (xSignifier < 0x10000000000000000000000000000) xExponent = 0;
            else xSignifier &= 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFF;
  
            return bytes16 (uint128 (
                (xSign ? 0x80000000000000000000000000000000 : 0) |
                (xExponent << 112) |
                xSignifier)); 
          }
        } else {
          if (delta > 0) {
            xSignifier <<= 1;
            xExponent -= 1;
          } else if (delta < 0) {
            ySignifier <<= 1;
            xExponent = yExponent - 1;
          }

          if (delta > 112) ySignifier = 1;
          else if (delta > 1) ySignifier = (ySignifier - 1 >> uint256 (delta - 1)) + 1;
          else if (delta < -112) xSignifier = 1;
          else if (delta < -1) xSignifier = (xSignifier - 1 >> uint256 (-delta - 1)) + 1;

          if (xSignifier >= ySignifier) xSignifier -= ySignifier;
          else {
            xSignifier = ySignifier - xSignifier;
            xSign = ySign;
          }

          if (xSignifier == 0)
            return POSITIVE_ZERO;

          uint256 msb = msb (xSignifier);

          if (msb == 113) {
            xSignifier = xSignifier >> 1 & 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFF;
            xExponent += 1;
          } else if (msb < 112) {
            uint256 shift = 112 - msb;
            if (xExponent > shift) {
              xSignifier = xSignifier << shift & 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFF;
              xExponent -= shift;
            } else {
              xSignifier <<= xExponent - 1;
              xExponent = 0;
            }
          } else xSignifier &= 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFF;

          if (xExponent == 0x7FFF)
            return xSign ? NEGATIVE_INFINITY : POSITIVE_INFINITY;
          else return bytes16 (uint128 (
              (xSign ? 0x80000000000000000000000000000000 : 0) |
              (xExponent << 112) |
              xSignifier));
        }
      }
    }
  }

  /**
   * Calculate x - y.  Special values behave in the following way:
   *
   * NaN - x = NaN for any x.
   * Infinity - x = Infinity for any finite x.
   * -Infinity - x = -Infinity for any finite x.
   * Infinity - -Infinity = Infinity.
   * -Infinity - Infinity = -Infinity.
   * Infinity - Infinity = -Infinity - -Infinity = NaN.
   *
   * @param x quadruple precision number
   * @param y quadruple precision number
   * @return quadruple precision number
   */
  function sub (bytes16 x, bytes16 y) internal pure returns (bytes16) {
    return add (x, y ^ 0x80000000000000000000000000000000);
  }

  /**
   * Calculate x * y.  Special values behave in the following way:
   *
   * NaN * x = NaN for any x.
   * Infinity * x = Infinity for any finite positive x.
   * Infinity * x = -Infinity for any finite negative x.
   * -Infinity * x = -Infinity for any finite positive x.
   * -Infinity * x = Infinity for any finite negative x.
   * Infinity * 0 = NaN.
   * -Infinity * 0 = NaN.
   * Infinity * Infinity = Infinity.
   * Infinity * -Infinity = -Infinity.
   * -Infinity * Infinity = -Infinity.
   * -Infinity * -Infinity = Infinity.
   *
   * @param x quadruple precision number
   * @param y quadruple precision number
   * @return quadruple precision number
   */
  function mul (bytes16 x, bytes16 y) internal pure returns (bytes16) {
    uint256 xExponent = uint128 (x) >> 112 & 0x7FFF;
    uint256 yExponent = uint128 (y) >> 112 & 0x7FFF;

    if (xExponent == 0x7FFF) {
      if (yExponent == 0x7FFF) {
        if (x == y) return x ^ y & 0x80000000000000000000000000000000;
        else if (x ^ y == 0x80000000000000000000000000000000) return x | y;
        else return NaN;
      } else {
        if (y & 0x7FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF == 0) return NaN;
        else return x ^ y & 0x80000000000000000000000000000000;
      }
    } else if (yExponent == 0x7FFF) {
        if (x & 0x7FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF == 0) return NaN;
        else return y ^ x & 0x80000000000000000000000000000000;
    } else {
      uint256 xSignifier = uint128 (x) & 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFF;
      if (xExponent == 0) xExponent = 1;
      else xSignifier |= 0x10000000000000000000000000000;

      uint256 ySignifier = uint128 (y) & 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFF;
      if (yExponent == 0) yExponent = 1;
      else ySignifier |= 0x10000000000000000000000000000;

      xSignifier *= ySignifier;
      if (xSignifier == 0)
        return (x ^ y) & 0x80000000000000000000000000000000 > 0 ?
            NEGATIVE_ZERO : POSITIVE_ZERO;

      xExponent += yExponent;

      uint256 msb =
        xSignifier >= 0x200000000000000000000000000000000000000000000000000000000 ? 225 :
        xSignifier >= 0x100000000000000000000000000000000000000000000000000000000 ? 224 :
        msb (xSignifier);

      if (xExponent + msb < 16496) { // Underflow
        xExponent = 0;
        xSignifier = 0;
      } else if (xExponent + msb < 16608) { // Subnormal
        if (xExponent < 16496)
          xSignifier >>= 16496 - xExponent;
        else if (xExponent > 16496)
          xSignifier <<= xExponent - 16496;
        xExponent = 0;
      } else if (xExponent + msb > 49373) {
        xExponent = 0x7FFF;
        xSignifier = 0;
      } else {
        if (msb > 112)
          xSignifier >>= msb - 112;
        else if (msb < 112)
          xSignifier <<= 112 - msb;

        xSignifier &= 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFF;

        xExponent = xExponent + msb - 16607;
      }

      return bytes16 (uint128 (uint128 ((x ^ y) & 0x80000000000000000000000000000000) |
          xExponent << 112 | xSignifier));
    }
  }

  /**
   * Calculate x / y.  Special values behave in the following way:
   *
   * NaN / x = NaN for any x.
   * x / NaN = NaN for any x.
   * Infinity / x = Infinity for any finite non-negative x.
   * Infinity / x = -Infinity for any finite negative x including -0.
   * -Infinity / x = -Infinity for any finite non-negative x.
   * -Infinity / x = Infinity for any finite negative x including -0.
   * x / Infinity = 0 for any finite non-negative x.
   * x / -Infinity = -0 for any finite non-negative x.
   * x / Infinity = -0 for any finite non-negative x including -0.
   * x / -Infinity = 0 for any finite non-negative x including -0.
   * 
   * Infinity / Infinity = NaN.
   * Infinity / -Infinity = -NaN.
   * -Infinity / Infinity = -NaN.
   * -Infinity / -Infinity = NaN.
   *
   * Division by zero behaves in the following way:
   *
   * x / 0 = Infinity for any finite positive x.
   * x / -0 = -Infinity for any finite positive x.
   * x / 0 = -Infinity for any finite negative x.
   * x / -0 = Infinity for any finite negative x.
   * 0 / 0 = NaN.
   * 0 / -0 = NaN.
   * -0 / 0 = NaN.
   * -0 / -0 = NaN.
   *
   * @param x quadruple precision number
   * @param y quadruple precision number
   * @return quadruple precision number
   */
  function div (bytes16 x, bytes16 y) internal pure returns (bytes16) {
    uint256 xExponent = uint128 (x) >> 112 & 0x7FFF;
    uint256 yExponent = uint128 (y) >> 112 & 0x7FFF;

    if (xExponent == 0x7FFF) {
      if (yExponent == 0x7FFF) return NaN;
      else return x ^ y & 0x80000000000000000000000000000000;
    } else if (yExponent == 0x7FFF) {
      if (y & 0x0000FFFFFFFFFFFFFFFFFFFFFFFFFFFF != 0) return NaN;
      else return POSITIVE_ZERO | (x ^ y) & 0x80000000000000000000000000000000;
    } else if (y & 0x7FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF == 0) {
      if (x & 0x7FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF == 0) return NaN;
      else return POSITIVE_INFINITY | (x ^ y) & 0x80000000000000000000000000000000;
    } else {
      uint256 ySignifier = uint128 (y) & 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFF;
      if (yExponent == 0) yExponent = 1;
      else ySignifier |= 0x10000000000000000000000000000;

      uint256 xSignifier = uint128 (x) & 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFF;
      if (xExponent == 0) {
        if (xSignifier != 0) {
          uint shift = 226 - msb (xSignifier);

          xSignifier <<= shift;

          xExponent = 1;
          yExponent += shift - 114;
        }
      }
      else {
        xSignifier = (xSignifier | 0x10000000000000000000000000000) << 114;
      }

      xSignifier = xSignifier / ySignifier;
      if (xSignifier == 0)
        return (x ^ y) & 0x80000000000000000000000000000000 > 0 ?
            NEGATIVE_ZERO : POSITIVE_ZERO;

      assert (xSignifier >= 0x1000000000000000000000000000);

      uint256 msb =
        xSignifier >= 0x80000000000000000000000000000 ? msb (xSignifier) :
        xSignifier >= 0x40000000000000000000000000000 ? 114 :
        xSignifier >= 0x20000000000000000000000000000 ? 113 : 112;

      if (xExponent + msb > yExponent + 16497) { // Overflow
        xExponent = 0x7FFF;
        xSignifier = 0;
      } else if (xExponent + msb + 16380  < yExponent) { // Underflow
        xExponent = 0;
        xSignifier = 0;
      } else if (xExponent + msb + 16268  < yExponent) { // Subnormal
        if (xExponent + 16380 > yExponent)
          xSignifier <<= xExponent + 16380 - yExponent;
        else if (xExponent + 16380 < yExponent)
          xSignifier >>= yExponent - xExponent - 16380;

        xExponent = 0;
      } else { // Normal
        if (msb > 112)
          xSignifier >>= msb - 112;

        xSignifier &= 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFF;

        xExponent = xExponent + msb + 16269 - yExponent;
      }

      return bytes16 (uint128 (uint128 ((x ^ y) & 0x80000000000000000000000000000000) |
          xExponent << 112 | xSignifier));
    }
  }

  /**
   * Calculate -x.
   *
   * @param x quadruple precision number
   * @return quadruple precision number
   */
  function neg (bytes16 x) internal pure returns (bytes16) {
    return x ^ 0x80000000000000000000000000000000;
  }

  /**
   * Calculate |x|.
   *
   * @param x quadruple precision number
   * @return quadruple precision number
   */
  function abs (bytes16 x) internal pure returns (bytes16) {
    return x & 0x7FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF;
  }

  /**
   * Calculate square root of x.  Return NaN on negative x excluding -0.
   *
   * @param x quadruple precision number
   * @return quadruple precision number
   */
  function sqrt (bytes16 x) internal pure returns (bytes16) {
    if (uint128 (x) >  0x80000000000000000000000000000000) return NaN;
    else {
      uint256 xExponent = uint128 (x) >> 112 & 0x7FFF;
      if (xExponent == 0x7FFF) return x;
      else {
        uint256 xSignifier = uint128 (x) & 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFF;
        if (xExponent == 0) xExponent = 1;
        else xSignifier |= 0x10000000000000000000000000000;

        if (xSignifier == 0) return POSITIVE_ZERO;

        bool oddExponent = xExponent & 0x1 == 0;
        xExponent = xExponent + 16383 >> 1;

        if (oddExponent) {
          if (xSignifier >= 0x10000000000000000000000000000)
            xSignifier <<= 113;
          else {
            uint256 msb = msb (xSignifier);
            uint256 shift = (226 - msb) & 0xFE;
            xSignifier <<= shift;
            xExponent -= shift - 112 >> 1;
          }
        } else {
          if (xSignifier >= 0x10000000000000000000000000000)
            xSignifier <<= 112;
          else {
            uint256 msb = msb (xSignifier);
            uint256 shift = (225 - msb) & 0xFE;
            xSignifier <<= shift;
            xExponent -= shift - 112 >> 1;
          }
        }

        uint256 r = 0x10000000000000000000000000000;
        r = (r + xSignifier / r) >> 1;
        r = (r + xSignifier / r) >> 1;
        r = (r + xSignifier / r) >> 1;
        r = (r + xSignifier / r) >> 1;
        r = (r + xSignifier / r) >> 1;
        r = (r + xSignifier / r) >> 1;
        r = (r + xSignifier / r) >> 1; // Seven iterations should be enough
        uint256 r1 = xSignifier / r;
        if (r1 < r) r = r1;

        return bytes16 (uint128 (xExponent << 112 | r & 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFF));
      }
    }
  }

  /**
   * Calculate binary logarithm of x.  Return NaN on negative x excluding -0.
   *
   * @param x quadruple precision number
   * @return quadruple precision number
   */
  function log_2 (bytes16 x) internal pure returns (bytes16) {
    if (uint128 (x) > 0x80000000000000000000000000000000) return NaN;
    else if (x == 0x3FFF0000000000000000000000000000) return POSITIVE_ZERO; 
    else {
      uint256 xExponent = uint128 (x) >> 112 & 0x7FFF;
      if (xExponent == 0x7FFF) return x;
      else {
        uint256 xSignifier = uint128 (x) & 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFF;
        if (xExponent == 0) xExponent = 1;
        else xSignifier |= 0x10000000000000000000000000000;

        if (xSignifier == 0) return NEGATIVE_INFINITY;

        bool resultNegative;
        uint256 resultExponent = 16495;
        uint256 resultSignifier;

        if (xExponent >= 0x3FFF) {
          resultNegative = false;
          resultSignifier = xExponent - 0x3FFF;
          xSignifier <<= 15;
        } else {
          resultNegative = true;
          if (xSignifier >= 0x10000000000000000000000000000) {
            resultSignifier = 0x3FFE - xExponent;
            xSignifier <<= 15;
          } else {
            uint256 msb = msb (xSignifier);
            resultSignifier = 16493 - msb;
            xSignifier <<= 127 - msb;
          }
        }

        if (xSignifier == 0x80000000000000000000000000000000) {
          if (resultNegative) resultSignifier += 1;
          uint256 shift = 112 - msb (resultSignifier);
          resultSignifier <<= shift;
          resultExponent -= shift;
        } else {
          uint256 bb = resultNegative ? 1 : 0;
          while (resultSignifier < 0x10000000000000000000000000000) {
            resultSignifier <<= 1;
            resultExponent -= 1;
  
            xSignifier *= xSignifier;
            uint256 b = xSignifier >> 255;
            resultSignifier += b ^ bb;
            xSignifier >>= 127 + b;
          }
        }

        return bytes16 (uint128 ((resultNegative ? 0x80000000000000000000000000000000 : 0) |
            resultExponent << 112 | resultSignifier & 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFF));
      }
    }
  }

  /**
   * Calculate natural logarithm of x.  Return NaN on negative x excluding -0.
   *
   * @param x quadruple precision number
   * @return quadruple precision number
   */
  function ln (bytes16 x) internal pure returns (bytes16) {
    return mul (log_2 (x), 0x3FFE62E42FEFA39EF35793C7673007E5);
  }

  /**
   * Calculate 2^x.
   *
   * @param x quadruple precision number
   * @return quadruple precision number
   */
  function pow_2 (bytes16 x) internal pure returns (bytes16) {
    bool xNegative = uint128 (x) > 0x80000000000000000000000000000000;
    uint256 xExponent = uint128 (x) >> 112 & 0x7FFF;
    uint256 xSignifier = uint128 (x) & 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFF;

    if (xExponent == 0x7FFF && xSignifier != 0) return NaN;
    else if (xExponent > 16397)
      return xNegative ? POSITIVE_ZERO : POSITIVE_INFINITY;
    else if (xExponent < 16255)
      return 0x3FFF0000000000000000000000000000;
    else {
      if (xExponent == 0) xExponent = 1;
      else xSignifier |= 0x10000000000000000000000000000;

      if (xExponent > 16367)
        xSignifier <<= xExponent - 16367;
      else if (xExponent < 16367)
        xSignifier >>= 16367 - xExponent;

      if (xNegative && xSignifier > 0x406E00000000000000000000000000000000)
        return POSITIVE_ZERO;

      if (!xNegative && xSignifier > 0x3FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF)
        return POSITIVE_INFINITY;

      uint256 resultExponent = xSignifier >> 128;
      xSignifier &= 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF;
      if (xNegative && xSignifier != 0) {
        xSignifier = ~xSignifier;
        resultExponent += 1;
      }

      uint256 resultSignifier = 0x80000000000000000000000000000000;
      if (xSignifier & 0x80000000000000000000000000000000 > 0) resultSignifier = resultSignifier * 0x16A09E667F3BCC908B2FB1366EA957D3E >> 128;
      if (xSignifier & 0x40000000000000000000000000000000 > 0) resultSignifier = resultSignifier * 0x1306FE0A31B7152DE8D5A46305C85EDEC >> 128;
      if (xSignifier & 0x20000000000000000000000000000000 > 0) resultSignifier = resultSignifier * 0x1172B83C7D517ADCDF7C8C50EB14A791F >> 128;
      if (xSignifier & 0x10000000000000000000000000000000 > 0) resultSignifier = resultSignifier * 0x10B5586CF9890F6298B92B71842A98363 >> 128;
      if (xSignifier & 0x8000000000000000000000000000000 > 0) resultSignifier = resultSignifier * 0x1059B0D31585743AE7C548EB68CA417FD >> 128;
      if (xSignifier & 0x4000000000000000000000000000000 > 0) resultSignifier = resultSignifier * 0x102C9A3E778060EE6F7CACA4F7A29BDE8 >> 128;
      if (xSignifier & 0x2000000000000000000000000000000 > 0) resultSignifier = resultSignifier * 0x10163DA9FB33356D84A66AE336DCDFA3F >> 128;
      if (xSignifier & 0x1000000000000000000000000000000 > 0) resultSignifier = resultSignifier * 0x100B1AFA5ABCBED6129AB13EC11DC9543 >> 128;
      if (xSignifier & 0x800000000000000000000000000000 > 0) resultSignifier = resultSignifier * 0x10058C86DA1C09EA1FF19D294CF2F679B >> 128;
      if (xSignifier & 0x400000000000000000000000000000 > 0) resultSignifier = resultSignifier * 0x1002C605E2E8CEC506D21BFC89A23A00F >> 128;
      if (xSignifier & 0x200000000000000000000000000000 > 0) resultSignifier = resultSignifier * 0x100162F3904051FA128BCA9C55C31E5DF >> 128;
      if (xSignifier & 0x100000000000000000000000000000 > 0) resultSignifier = resultSignifier * 0x1000B175EFFDC76BA38E31671CA939725 >> 128;
      if (xSignifier & 0x80000000000000000000000000000 > 0) resultSignifier = resultSignifier * 0x100058BA01FB9F96D6CACD4B180917C3D >> 128;
      if (xSignifier & 0x40000000000000000000000000000 > 0) resultSignifier = resultSignifier * 0x10002C5CC37DA9491D0985C348C68E7B3 >> 128;
      if (xSignifier & 0x20000000000000000000000000000 > 0) resultSignifier = resultSignifier * 0x1000162E525EE054754457D5995292026 >> 128;
      if (xSignifier & 0x10000000000000000000000000000 > 0) resultSignifier = resultSignifier * 0x10000B17255775C040618BF4A4ADE83FC >> 128;
      if (xSignifier & 0x8000000000000000000000000000 > 0) resultSignifier = resultSignifier * 0x1000058B91B5BC9AE2EED81E9B7D4CFAB >> 128;
      if (xSignifier & 0x4000000000000000000000000000 > 0) resultSignifier = resultSignifier * 0x100002C5C89D5EC6CA4D7C8ACC017B7C9 >> 128;
      if (xSignifier & 0x2000000000000000000000000000 > 0) resultSignifier = resultSignifier * 0x10000162E43F4F831060E02D839A9D16D >> 128;
      if (xSignifier & 0x1000000000000000000000000000 > 0) resultSignifier = resultSignifier * 0x100000B1721BCFC99D9F890EA06911763 >> 128;
      if (xSignifier & 0x800000000000000000000000000 > 0) resultSignifier = resultSignifier * 0x10000058B90CF1E6D97F9CA14DBCC1628 >> 128;
      if (xSignifier & 0x400000000000000000000000000 > 0) resultSignifier = resultSignifier * 0x1000002C5C863B73F016468F6BAC5CA2B >> 128;
      if (xSignifier & 0x200000000000000000000000000 > 0) resultSignifier = resultSignifier * 0x100000162E430E5A18F6119E3C02282A5 >> 128;
      if (xSignifier & 0x100000000000000000000000000 > 0) resultSignifier = resultSignifier * 0x1000000B1721835514B86E6D96EFD1BFE >> 128;
      if (xSignifier & 0x80000000000000000000000000 > 0) resultSignifier = resultSignifier * 0x100000058B90C0B48C6BE5DF846C5B2EF >> 128;
      if (xSignifier & 0x40000000000000000000000000 > 0) resultSignifier = resultSignifier * 0x10000002C5C8601CC6B9E94213C72737A >> 128;
      if (xSignifier & 0x20000000000000000000000000 > 0) resultSignifier = resultSignifier * 0x1000000162E42FFF037DF38AA2B219F06 >> 128;
      if (xSignifier & 0x10000000000000000000000000 > 0) resultSignifier = resultSignifier * 0x10000000B17217FBA9C739AA5819F44F9 >> 128;
      if (xSignifier & 0x8000000000000000000000000 > 0) resultSignifier = resultSignifier * 0x1000000058B90BFCDEE5ACD3C1CEDC823 >> 128;
      if (xSignifier & 0x4000000000000000000000000 > 0) resultSignifier = resultSignifier * 0x100000002C5C85FE31F35A6A30DA1BE50 >> 128;
      if (xSignifier & 0x2000000000000000000000000 > 0) resultSignifier = resultSignifier * 0x10000000162E42FF0999CE3541B9FFFCF >> 128;
      if (xSignifier & 0x1000000000000000000000000 > 0) resultSignifier = resultSignifier * 0x100000000B17217F80F4EF5AADDA45554 >> 128;
      if (xSignifier & 0x800000000000000000000000 > 0) resultSignifier = resultSignifier * 0x10000000058B90BFBF8479BD5A81B51AD >> 128;
      if (xSignifier & 0x400000000000000000000000 > 0) resultSignifier = resultSignifier * 0x1000000002C5C85FDF84BD62AE30A74CC >> 128;
      if (xSignifier & 0x200000000000000000000000 > 0) resultSignifier = resultSignifier * 0x100000000162E42FEFB2FED257559BDAA >> 128;
      if (xSignifier & 0x100000000000000000000000 > 0) resultSignifier = resultSignifier * 0x1000000000B17217F7D5A7716BBA4A9AE >> 128;
      if (xSignifier & 0x80000000000000000000000 > 0) resultSignifier = resultSignifier * 0x100000000058B90BFBE9DDBAC5E109CCE >> 128;
      if (xSignifier & 0x40000000000000000000000 > 0) resultSignifier = resultSignifier * 0x10000000002C5C85FDF4B15DE6F17EB0D >> 128;
      if (xSignifier & 0x20000000000000000000000 > 0) resultSignifier = resultSignifier * 0x1000000000162E42FEFA494F1478FDE05 >> 128;
      if (xSignifier & 0x10000000000000000000000 > 0) resultSignifier = resultSignifier * 0x10000000000B17217F7D20CF927C8E94C >> 128;
      if (xSignifier & 0x8000000000000000000000 > 0) resultSignifier = resultSignifier * 0x1000000000058B90BFBE8F71CB4E4B33D >> 128;
      if (xSignifier & 0x4000000000000000000000 > 0) resultSignifier = resultSignifier * 0x100000000002C5C85FDF477B662B26945 >> 128;
      if (xSignifier & 0x2000000000000000000000 > 0) resultSignifier = resultSignifier * 0x10000000000162E42FEFA3AE53369388C >> 128;
      if (xSignifier & 0x1000000000000000000000 > 0) resultSignifier = resultSignifier * 0x100000000000B17217F7D1D351A389D40 >> 128;
      if (xSignifier & 0x800000000000000000000 > 0) resultSignifier = resultSignifier * 0x10000000000058B90BFBE8E8B2D3D4EDE >> 128;
      if (xSignifier & 0x400000000000000000000 > 0) resultSignifier = resultSignifier * 0x1000000000002C5C85FDF4741BEA6E77E >> 128;
      if (xSignifier & 0x200000000000000000000 > 0) resultSignifier = resultSignifier * 0x100000000000162E42FEFA39FE95583C2 >> 128;
      if (xSignifier & 0x100000000000000000000 > 0) resultSignifier = resultSignifier * 0x1000000000000B17217F7D1CFB72B45E1 >> 128;
      if (xSignifier & 0x80000000000000000000 > 0) resultSignifier = resultSignifier * 0x100000000000058B90BFBE8E7CC35C3F0 >> 128;
      if (xSignifier & 0x40000000000000000000 > 0) resultSignifier = resultSignifier * 0x10000000000002C5C85FDF473E242EA38 >> 128;
      if (xSignifier & 0x20000000000000000000 > 0) resultSignifier = resultSignifier * 0x1000000000000162E42FEFA39F02B772C >> 128;
      if (xSignifier & 0x10000000000000000000 > 0) resultSignifier = resultSignifier * 0x10000000000000B17217F7D1CF7D83C1A >> 128;
      if (xSignifier & 0x8000000000000000000 > 0) resultSignifier = resultSignifier * 0x1000000000000058B90BFBE8E7BDCBE2E >> 128;
      if (xSignifier & 0x4000000000000000000 > 0) resultSignifier = resultSignifier * 0x100000000000002C5C85FDF473DEA871F >> 128;
      if (xSignifier & 0x2000000000000000000 > 0) resultSignifier = resultSignifier * 0x10000000000000162E42FEFA39EF44D91 >> 128;
      if (xSignifier & 0x1000000000000000000 > 0) resultSignifier = resultSignifier * 0x100000000000000B17217F7D1CF79E949 >> 128;
      if (xSignifier & 0x800000000000000000 > 0) resultSignifier = resultSignifier * 0x10000000000000058B90BFBE8E7BCE544 >> 128;
      if (xSignifier & 0x400000000000000000 > 0) resultSignifier = resultSignifier * 0x1000000000000002C5C85FDF473DE6ECA >> 128;
      if (xSignifier & 0x200000000000000000 > 0) resultSignifier = resultSignifier * 0x100000000000000162E42FEFA39EF366F >> 128;
      if (xSignifier & 0x100000000000000000 > 0) resultSignifier = resultSignifier * 0x1000000000000000B17217F7D1CF79AFA >> 128;
      if (xSignifier & 0x80000000000000000 > 0) resultSignifier = resultSignifier * 0x100000000000000058B90BFBE8E7BCD6D >> 128;
      if (xSignifier & 0x40000000000000000 > 0) resultSignifier = resultSignifier * 0x10000000000000002C5C85FDF473DE6B2 >> 128;
      if (xSignifier & 0x20000000000000000 > 0) resultSignifier = resultSignifier * 0x1000000000000000162E42FEFA39EF358 >> 128;
      if (xSignifier & 0x10000000000000000 > 0) resultSignifier = resultSignifier * 0x10000000000000000B17217F7D1CF79AB >> 128;
      if (xSignifier & 0x8000000000000000 > 0) resultSignifier = resultSignifier * 0x1000000000000000058B90BFBE8E7BCD5 >> 128;
      if (xSignifier & 0x4000000000000000 > 0) resultSignifier = resultSignifier * 0x100000000000000002C5C85FDF473DE6A >> 128;
      if (xSignifier & 0x2000000000000000 > 0) resultSignifier = resultSignifier * 0x10000000000000000162E42FEFA39EF34 >> 128;
      if (xSignifier & 0x1000000000000000 > 0) resultSignifier = resultSignifier * 0x100000000000000000B17217F7D1CF799 >> 128;
      if (xSignifier & 0x800000000000000 > 0) resultSignifier = resultSignifier * 0x10000000000000000058B90BFBE8E7BCC >> 128;
      if (xSignifier & 0x400000000000000 > 0) resultSignifier = resultSignifier * 0x1000000000000000002C5C85FDF473DE5 >> 128;
      if (xSignifier & 0x200000000000000 > 0) resultSignifier = resultSignifier * 0x100000000000000000162E42FEFA39EF2 >> 128;
      if (xSignifier & 0x100000000000000 > 0) resultSignifier = resultSignifier * 0x1000000000000000000B17217F7D1CF78 >> 128;
      if (xSignifier & 0x80000000000000 > 0) resultSignifier = resultSignifier * 0x100000000000000000058B90BFBE8E7BB >> 128;
      if (xSignifier & 0x40000000000000 > 0) resultSignifier = resultSignifier * 0x10000000000000000002C5C85FDF473DD >> 128;
      if (xSignifier & 0x20000000000000 > 0) resultSignifier = resultSignifier * 0x1000000000000000000162E42FEFA39EE >> 128;
      if (xSignifier & 0x10000000000000 > 0) resultSignifier = resultSignifier * 0x10000000000000000000B17217F7D1CF6 >> 128;
      if (xSignifier & 0x8000000000000 > 0) resultSignifier = resultSignifier * 0x1000000000000000000058B90BFBE8E7A >> 128;
      if (xSignifier & 0x4000000000000 > 0) resultSignifier = resultSignifier * 0x100000000000000000002C5C85FDF473C >> 128;
      if (xSignifier & 0x2000000000000 > 0) resultSignifier = resultSignifier * 0x10000000000000000000162E42FEFA39D >> 128;
      if (xSignifier & 0x1000000000000 > 0) resultSignifier = resultSignifier * 0x100000000000000000000B17217F7D1CE >> 128;
      if (xSignifier & 0x800000000000 > 0) resultSignifier = resultSignifier * 0x10000000000000000000058B90BFBE8E6 >> 128;
      if (xSignifier & 0x400000000000 > 0) resultSignifier = resultSignifier * 0x1000000000000000000002C5C85FDF472 >> 128;
      if (xSignifier & 0x200000000000 > 0) resultSignifier = resultSignifier * 0x100000000000000000000162E42FEFA38 >> 128;
      if (xSignifier & 0x100000000000 > 0) resultSignifier = resultSignifier * 0x1000000000000000000000B17217F7D1B >> 128;
      if (xSignifier & 0x80000000000 > 0) resultSignifier = resultSignifier * 0x100000000000000000000058B90BFBE8D >> 128;
      if (xSignifier & 0x40000000000 > 0) resultSignifier = resultSignifier * 0x10000000000000000000002C5C85FDF46 >> 128;
      if (xSignifier & 0x20000000000 > 0) resultSignifier = resultSignifier * 0x1000000000000000000000162E42FEFA2 >> 128;
      if (xSignifier & 0x10000000000 > 0) resultSignifier = resultSignifier * 0x10000000000000000000000B17217F7D0 >> 128;
      if (xSignifier & 0x8000000000 > 0) resultSignifier = resultSignifier * 0x1000000000000000000000058B90BFBE7 >> 128;
      if (xSignifier & 0x4000000000 > 0) resultSignifier = resultSignifier * 0x100000000000000000000002C5C85FDF3 >> 128;
      if (xSignifier & 0x2000000000 > 0) resultSignifier = resultSignifier * 0x10000000000000000000000162E42FEF9 >> 128;
      if (xSignifier & 0x1000000000 > 0) resultSignifier = resultSignifier * 0x100000000000000000000000B17217F7C >> 128;
      if (xSignifier & 0x800000000 > 0) resultSignifier = resultSignifier * 0x10000000000000000000000058B90BFBD >> 128;
      if (xSignifier & 0x400000000 > 0) resultSignifier = resultSignifier * 0x1000000000000000000000002C5C85FDE >> 128;
      if (xSignifier & 0x200000000 > 0) resultSignifier = resultSignifier * 0x100000000000000000000000162E42FEE >> 128;
      if (xSignifier & 0x100000000 > 0) resultSignifier = resultSignifier * 0x1000000000000000000000000B17217F6 >> 128;
      if (xSignifier & 0x80000000 > 0) resultSignifier = resultSignifier * 0x100000000000000000000000058B90BFA >> 128;
      if (xSignifier & 0x40000000 > 0) resultSignifier = resultSignifier * 0x10000000000000000000000002C5C85FC >> 128;
      if (xSignifier & 0x20000000 > 0) resultSignifier = resultSignifier * 0x1000000000000000000000000162E42FD >> 128;
      if (xSignifier & 0x10000000 > 0) resultSignifier = resultSignifier * 0x10000000000000000000000000B17217E >> 128;
      if (xSignifier & 0x8000000 > 0) resultSignifier = resultSignifier * 0x1000000000000000000000000058B90BE >> 128;
      if (xSignifier & 0x4000000 > 0) resultSignifier = resultSignifier * 0x100000000000000000000000002C5C85E >> 128;
      if (xSignifier & 0x2000000 > 0) resultSignifier = resultSignifier * 0x10000000000000000000000000162E42E >> 128;
      if (xSignifier & 0x1000000 > 0) resultSignifier = resultSignifier * 0x100000000000000000000000000B17216 >> 128;
      if (xSignifier & 0x800000 > 0) resultSignifier = resultSignifier * 0x10000000000000000000000000058B90A >> 128;
      if (xSignifier & 0x400000 > 0) resultSignifier = resultSignifier * 0x1000000000000000000000000002C5C84 >> 128;
      if (xSignifier & 0x200000 > 0) resultSignifier = resultSignifier * 0x100000000000000000000000000162E41 >> 128;
      if (xSignifier & 0x100000 > 0) resultSignifier = resultSignifier * 0x1000000000000000000000000000B1720 >> 128;
      if (xSignifier & 0x80000 > 0) resultSignifier = resultSignifier * 0x100000000000000000000000000058B8F >> 128;
      if (xSignifier & 0x40000 > 0) resultSignifier = resultSignifier * 0x10000000000000000000000000002C5C7 >> 128;
      if (xSignifier & 0x20000 > 0) resultSignifier = resultSignifier * 0x1000000000000000000000000000162E3 >> 128;
      if (xSignifier & 0x10000 > 0) resultSignifier = resultSignifier * 0x10000000000000000000000000000B171 >> 128;
      if (xSignifier & 0x8000 > 0) resultSignifier = resultSignifier * 0x1000000000000000000000000000058B8 >> 128;
      if (xSignifier & 0x4000 > 0) resultSignifier = resultSignifier * 0x100000000000000000000000000002C5B >> 128;
      if (xSignifier & 0x2000 > 0) resultSignifier = resultSignifier * 0x10000000000000000000000000000162D >> 128;
      if (xSignifier & 0x1000 > 0) resultSignifier = resultSignifier * 0x100000000000000000000000000000B16 >> 128;
      if (xSignifier & 0x800 > 0) resultSignifier = resultSignifier * 0x10000000000000000000000000000058A >> 128;
      if (xSignifier & 0x400 > 0) resultSignifier = resultSignifier * 0x1000000000000000000000000000002C4 >> 128;
      if (xSignifier & 0x200 > 0) resultSignifier = resultSignifier * 0x100000000000000000000000000000161 >> 128;
      if (xSignifier & 0x100 > 0) resultSignifier = resultSignifier * 0x1000000000000000000000000000000B0 >> 128;
      if (xSignifier & 0x80 > 0) resultSignifier = resultSignifier * 0x100000000000000000000000000000057 >> 128;
      if (xSignifier & 0x40 > 0) resultSignifier = resultSignifier * 0x10000000000000000000000000000002B >> 128;
      if (xSignifier & 0x20 > 0) resultSignifier = resultSignifier * 0x100000000000000000000000000000015 >> 128;
      if (xSignifier & 0x10 > 0) resultSignifier = resultSignifier * 0x10000000000000000000000000000000A >> 128;
      if (xSignifier & 0x8 > 0) resultSignifier = resultSignifier * 0x100000000000000000000000000000004 >> 128;
      if (xSignifier & 0x4 > 0) resultSignifier = resultSignifier * 0x100000000000000000000000000000001 >> 128;

      if (!xNegative) {
        resultSignifier = resultSignifier >> 15 & 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFF;
        resultExponent += 0x3FFF;
      } else if (resultExponent <= 0x3FFE) {
        resultSignifier = resultSignifier >> 15 & 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFF;
        resultExponent = 0x3FFF - resultExponent;
      } else {
        resultSignifier = resultSignifier >> resultExponent - 16367;
        resultExponent = 0;
      }

      return bytes16 (uint128 (resultExponent << 112 | resultSignifier));
    }
  }

  /**
   * Calculate e^x.
   *
   * @param x quadruple precision number
   * @return quadruple precision number
   */
  function exp (bytes16 x) internal pure returns (bytes16) {
    return pow_2 (mul (x, 0x3FFF71547652B82FE1777D0FFDA0D23A));
  }

  /**
   * Get index of the most significant non-zero bit in binary representation of
   * x.  Reverts if x is zero.
   *
   * @return index of the most significant non-zero bit in binary representation
   *         of x
   */
  function msb (uint256 x) private pure returns (uint256) {
    require (x > 0);

    uint256 result = 0;

    if (x >= 0x100000000000000000000000000000000) { x >>= 128; result += 128; }
    if (x >= 0x10000000000000000) { x >>= 64; result += 64; }
    if (x >= 0x100000000) { x >>= 32; result += 32; }
    if (x >= 0x10000) { x >>= 16; result += 16; }
    if (x >= 0x100) { x >>= 8; result += 8; }
    if (x >= 0x10) { x >>= 4; result += 4; }
    if (x >= 0x4) { x >>= 2; result += 2; }
    if (x >= 0x2) result += 1; // No need to shift x anymore

    return result;
  }
}

// File: contracts/erc/ERC20.sol

// (c) Kallol Borah, 2020
// Base ERC20 implementation.

pragma solidity >=0.5.0 <0.7.0;


contract ERC20 {

    using ABDKMathQuad for uint256;
    using ABDKMathQuad for int256;
    using ABDKMathQuad for bytes16;

    //address of the issuer of the Via, set once, never reset again
    address payable issuer;

    //allowing 2-floating points for Via tokens
    uint8 public decimals;
    
    //variables
    bytes16 totalSupply_;

    //Via balances held by this address
    mapping(address => bytes16) public balances;
    //Delegates allowed to access this address
    mapping(address => mapping (address => bytes16)) allowed;

    //erc20 standard events
    event Approval(address indexed tokenOwner, address indexed spender, uint tokens);
    event Transfer(address indexed from, address indexed to, uint tokens);

    //erc20 standard functions
    function totalSupply() public view returns (uint){
        return ABDKMathQuad.toUInt(totalSupply_);
    }

    function balanceOf(address tokenOwner) public view returns (uint){
        return ABDKMathQuad.toUInt(balances[tokenOwner]);
    }

    function transfer(address receiver, uint tokens) public returns (bool){
        require(ABDKMathQuad.cmp(ABDKMathQuad.fromUInt(tokens),balances[address(this)])==-1 || 
                ABDKMathQuad.cmp(ABDKMathQuad.fromUInt(tokens),balances[address(this)])==0);
        balances[address(this)] = ABDKMathQuad.sub(balances[address(this)], ABDKMathQuad.fromUInt(tokens));
        balances[receiver] = ABDKMathQuad.add(balances[receiver], ABDKMathQuad.fromUInt(tokens));
        emit Transfer(address(this), receiver, tokens);
        return true;
    }    

    function approve(address spender, uint tokens)  public returns (bool){
        allowed[msg.sender][spender] = ABDKMathQuad.fromUInt(tokens);
        emit Approval(msg.sender, spender, tokens);
        return true;
    }

    function allowance(address tokenOwner, address spender) public view returns (uint){
        return ABDKMathQuad.toUInt(allowed[tokenOwner][spender]);
    }

    function transferFrom(address owner, address buyer, uint tokens) external returns (bool){
        require(ABDKMathQuad.cmp(ABDKMathQuad.fromUInt(tokens), balances[owner])==-1 ||
                ABDKMathQuad.cmp(ABDKMathQuad.fromUInt(tokens), balances[owner])==0);
        //require(ABDKMathQuad.cmp(ABDKMathQuad.fromUInt(tokens), balances[owner])==0);
        require(ABDKMathQuad.cmp(ABDKMathQuad.fromUInt(tokens), allowed[owner][msg.sender])==-1 || ABDKMathQuad.cmp(ABDKMathQuad.fromUInt(tokens), allowed[owner][msg.sender])==0);
        balances[owner] = ABDKMathQuad.sub(balances[owner], ABDKMathQuad.fromUInt(tokens));
        allowed[owner][msg.sender] = ABDKMathQuad.sub(allowed[owner][msg.sender], ABDKMathQuad.fromUInt(tokens));
        balances[buyer] = ABDKMathQuad.add(balances[buyer], ABDKMathQuad.fromUInt(tokens));
        emit Transfer(owner, buyer, tokens);
        return true;
    }

}

// File: contracts/interfaces/Oracle.sol

//(c) Kallol Borah, 2020
// Via oracle interface definition

pragma solidity >=0.5.0 <0.7.0;

interface Oracle{

    function request(bytes32 _currency, bytes32 _ratetype, bytes32 _tokenType, address payable _tokenContract)
        external
        payable
        returns (bytes32);
    
    function setCallbackId(bytes32 _queryId, bytes32 _callbackId) external;

}

// File: @openzeppelin/upgrades/contracts/Initializable.sol

pragma solidity >=0.4.24 <0.7.0;


/**
 * @title Initializable
 *
 * @dev Helper contract to support initializer functions. To use it, replace
 * the constructor with a function that has the `initializer` modifier.
 * WARNING: Unlike constructors, initializer functions must be manually
 * invoked. This applies both to deploying an Initializable contract, as well
 * as extending an Initializable contract via inheritance.
 * WARNING: When used with inheritance, manual care must be taken to not invoke
 * a parent initializer twice, or ensure that all initializers are idempotent,
 * because this is not dealt with automatically as with constructors.
 */
contract Initializable {

  /**
   * @dev Indicates that the contract has been initialized.
   */
  bool private initialized;

  /**
   * @dev Indicates that the contract is in the process of being initialized.
   */
  bool private initializing;

  /**
   * @dev Modifier to use in the initializer function of a contract.
   */
  modifier initializer() {
    require(initializing || isConstructor() || !initialized, "Contract instance has already been initialized");

    bool isTopLevelCall = !initializing;
    if (isTopLevelCall) {
      initializing = true;
      initialized = true;
    }

    _;

    if (isTopLevelCall) {
      initializing = false;
    }
  }

  /// @dev Returns true if and only if the function is running in the constructor
  function isConstructor() private view returns (bool) {
    // extcodesize checks the size of the code stored in an address, and
    // address returns the current address. Since the code is still not
    // deployed when running a constructor, any checks on its code size will
    // yield zero, making it an effective way to detect if a contract is
    // under construction or not.
    address self = address(this);
    uint256 cs;
    assembly { cs := extcodesize(self) }
    return cs == 0;
  }

  // Reserved storage space to allow for layout changes in the future.
  uint256[50] private ______gap;
}

// File: @openzeppelin/contracts-ethereum-package/contracts/GSN/Context.sol

pragma solidity ^0.5.0;


/*
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with GSN meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
contract Context is Initializable {
    // Empty internal constructor, to prevent people from mistakenly deploying
    // an instance of this contract, which should be used via inheritance.
    constructor () internal { }
    // solhint-disable-previous-line no-empty-blocks

    function _msgSender() internal view returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

// File: @openzeppelin/contracts-ethereum-package/contracts/ownership/Ownable.sol

pragma solidity ^0.5.0;



/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be aplied to your functions to restrict their use to
 * the owner.
 */
contract Ownable is Initializable, Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    function initialize(address sender) public initializer {
        _owner = sender;
        emit OwnershipTransferred(address(0), _owner);
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(isOwner(), "Ownable: caller is not the owner");
        _;
    }

    /**
     * @dev Returns true if the caller is the current owner.
     */
    function isOwner() public view returns (bool) {
        return _msgSender() == _owner;
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * > Note: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() public onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public onlyOwner {
        _transferOwnership(newOwner);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     */
    function _transferOwnership(address newOwner) internal {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }

    uint256[50] private ______gap;
}

// File: contracts/interfaces/ViaFactory.sol

// (c) Kallol Borah, 2020
// Interface definition of the Via cash and bond factory.

pragma solidity >=0.5.0 <0.7.0;

interface ViaFactory{

    function getTokenCount() external view returns(uint tokenCount);

    function getToken(uint256 n) external view returns(address);

    function getName(address viaAddress) external view returns(bytes32);

    function getType(address viaAddress) external view returns(bytes32);

    function getNameAndType(address viaAddress) external view returns(bytes32, bytes32);

    function getProduct(bytes32 symbol) external view returns(address);

    function getIssuer(bytes32 tokenType, bytes32 tokenName) external view returns(address);

    function createToken(address _target, bytes32 tokenName, bytes32 tokenProduct, bytes32 tokenSymbol) external returns(address);

}

// File: contracts/interfaces/ViaCash.sol

// (c) Kallol Borah, 2020
// Interface of the Via cash token.

pragma solidity >=0.5.0 <0.7.0;


interface ViaCash{

    function convert(bytes32 txId, bytes16 result, bytes32 rtype) external;

    function requestAddToBalance(bytes16 tokens, address sender) external returns (bool);

    function requestDeductFromBalance(bytes16 tokens, address receiver) external returns (bytes16);

    function transferFrom(address sender, address receiver, uint256 tokens) external returns (bool);

}

// File: contracts/interfaces/ViaBond.sol

// (c) Kallol Borah, 2020
// Interface definition of the Via bond token.

pragma solidity >=0.5.0 <0.7.0;

interface ViaBond{

    function convert(bytes32 txId, bytes16 result, bytes32 rtype) external;

    function transferForward(bytes32 _symbol, address _forwarder, address _sender, address _receiver, uint256 _tokens) external returns (bool);

    function requestIssue(bytes16 amount, address payer, bytes32 currency, address cashContract) external returns(bool);

}

// File: contracts/interfaces/ViaToken.sol

// (c) Kallol Borah, 2020
// Interface definition of the token issued by Bond issuer

pragma solidity >=0.5.0 <0.7.0;

interface ViaToken{

    function transferToken(address sender, address receiver, uint256 tokens) external returns (bool);

    function reduceSupply(bytes16 amount) external;

    function reduceBalance(address party, bytes16 amount) external;

    function addBalance(address party, bytes16 amount) external;

    function addTotalSupply(bytes16 amount) external;

    function requestTransfer(address receiver, uint tokens) external returns (bool);

}

// File: contracts/utilities/StringUtils.sol

pragma solidity >=0.5.0 <0.7.0;

library stringutils { // Only relevant functions
    
    //added from https://ethereum.stackexchange.com/questions/62371/convert-a-string-to-a-uint256-with-error-handling
    function stringToUint(string memory s) public pure returns (uint) {
        bool hasError = false;
        bytes memory b = bytes(s);
        uint result = 0;
        uint oldResult = 0;
        for (uint i = 0; i < b.length; i++) { // c = b[i] was not needed
            if (uint(uint8(b[i])) >= 48 && uint(uint8(b[i])) <= 57) {
                // store old value so we can check for overflows
                oldResult = result;
                result = result * 10 + (uint(uint8(b[i])) - 48); // bytes and int are not compatible with the operator -.
                // prevent overflows
                if(oldResult > result ) {
                    // we can only get here if the result overflowed and is smaller than last stored value
                    hasError = true;
                }
            } else {
                hasError = true;
            }
        }
        return (result); 
    }

    function substring(string memory str, uint startIndex, uint endIndex) public pure returns (string memory) {
        bytes memory strBytes = bytes(str);
        bytes memory result = new bytes(endIndex-startIndex);
        for(uint i = startIndex; i < endIndex; i++) {
            result[i-startIndex] = strBytes[i];
        }
        return string(result);
    }

    function append(string memory a, string memory b) public pure returns (string memory) {
        return string(abi.encodePacked(a, b));
    }

    //convert from string to bytes32
    function stringToBytes32(string memory source) public pure returns (bytes32 result) {
        bytes memory tempEmptyStringTest = bytes(source);
        if (tempEmptyStringTest.length == 0) {
            return 0x0;
        }

        assembly {
            result := mload(add(source, 32))
        }
    }

    function bytes32ToString(bytes32 _bytes32) public pure returns (string memory) {
        uint8 i = 0;
        while(i < 32 && _bytes32[i] != 0) {
            i++;
        }
        bytes memory bytesArray = new bytes(i);
        for (i = 0; i < 32 && _bytes32[i] != 0; i++) {
            bytesArray[i] = _bytes32[i];
        }
        return string(bytesArray);
    }

}

// File: contracts/Bond.sol

// (c) Kallol Borah, 2020
// Implementation of the Via zero coupon bond.

pragma solidity >=0.5.0 <0.7.0;











contract Bond is ViaBond, ERC20, Initializable, Ownable {

    using stringutils for *;

    using ABDKMathQuad for uint256;
    using ABDKMathQuad for int256;
    using ABDKMathQuad for bytes16;

    //via token factory address
    ViaFactory private factory;

    //via oracle
    Oracle private oracle;
    address viaoracle;

    //name of Via token (eg, Via-USD)
    string public name;
    string public symbol;
    
    //token address
    address private token;

    //name and symbol of bond sent by Token for transfer
    bytes32 bondSymbol;
    bytes32 public bondName;

    //forwarding token address
    address private forwarder;

    //a Via bond has some value, corresponds to a fiat currency
    //can have many purchasers and a issuer that have agreed to a zero coupon rate which determines the start price of the bond
    //and a tenure in unix timestamps of seconds counted from 1970-01-01. Via bonds are of one year tenure.
    struct bond{
        address[] counterParties;
        bytes16 parValue;
        bytes16 price;
        bytes16 purchasedIssueAmount;
        bytes16 collateralAmount;
        bytes32 collateralCurrency;
        uint256 timeSubscribed;
    }

    //mapping issuer (address) to address of bond token (address) which acts as identifier for bonds on offer
    mapping(address => mapping (address => bond)) public issues;

    //mapping purchaser (address) to address of bond token (address) which acts as identifier for bonds subscribed
    mapping(address => mapping (address => bond)) public purchases;

    //array of issues of this via bond, where bond IDs are their addresses of their token issues
    address[] private bondsIssued;

    //array of issuers
    address[] private issuers;

    //data structure holding details of currency conversion requests pending on oraclize
    struct conversion{
        bytes32 operation;
        address party;
        bytes16 amount;
        bytes32 paid_in_currency;
        bytes32 EthXid;
        bytes16 EthXvalue;
        bytes32 bond_currency;
        bytes16 ViaXvalue;
        bytes32 ViaRateId;
        bytes16 ViaRateValue;
    }

    //queue of pending conversion requests with each pending request mapped to a request_id returned by oraclize
    mapping(bytes32 => conversion) private conversionQ;

    //events to capture and report to Via oracle
    event ViaBondIssued(bytes32 currency, uint256 value, uint256 price, uint256 tenure);
    event ViaBondRedeemed(bytes32 currency, uint256 value, uint256 price, uint256 tenure);

    //mutex
    bool lock;

    //initiliaze proxies
    function initialize(bytes32 _name, bytes32 _type, address _owner, address _oracle, address _token) public initializer {
        Ownable.initialize(_owner);
        factory = ViaFactory(_owner);
        oracle = Oracle(_oracle);
        viaoracle = _oracle;
        name = string(abi.encodePacked(_name));
        symbol = string(abi.encodePacked(_type));
        bondName = _name;
        token = _token;
        lock = false;
        decimals = 2;
    }

    //handling pay in of ether for issue of via bond tokens
    function() external payable{
        //ether paid in
        require(msg.value !=0);
        //only to pay in ether
        require(msg.data.length==0);
        //issue via bond tokens
        issue(ABDKMathQuad.fromUInt(msg.value), msg.sender, "ether", address(this));
    }

    //forwarding call from issued bond token if at all such a call arrives
    function transferForward(bytes32 _symbol, address _forwarder, address _sender, address _receiver, uint256 _tokens) external returns (bool){
        require(factory.getProduct(_symbol)==_forwarder);
        bondSymbol = _symbol;
        forwarder = _forwarder;
        if(transferFrom(_sender, _receiver, _tokens))
            return true;
        else
            return false;
    }

    //overriding this function of ERC20 standard
    function transferFrom(address sender, address receiver, uint256 tokens) public returns (bool){
        //check if tokens are being transferred to this bond contract
        if(receiver == address(this) || receiver == forwarder){
            //if token name is the same, this transfer has to be redeemed
            if(redeem(ABDKMathQuad.fromUInt(tokens), sender, bondName, "ViaBond"))
                return true;
            else
                return false;
        }
        else {
            //bond tokens are being sent to a user account
            //sender is transferring its full purchase amount of bonds
            address issuedBond = factory.getProduct(bondSymbol);
            if(issuedBond!=address(0x0)){
                if(ABDKMathQuad.cmp(purchases[sender][issuedBond].purchasedIssueAmount, ABDKMathQuad.fromUInt(tokens))==0){
                    require(!lock);
                    lock = true;
                    if(ViaToken(issuedBond).transferToken(sender, receiver, tokens)){
                        purchases[receiver][issuedBond] = issues[sender][issuedBond];
                        delete purchases[sender][issuedBond];
                        lock = false;
                        return true;
                    }
                    else{
                        lock = false;
                        return false;
                    }
                }
                return false;
            }
            return false;
        }
    }

    function requestIssue(bytes16 amount, address payer, bytes32 currency, address cashContract) external returns(bool){
        require(factory.getType(msg.sender) == "ViaCash");
        return(issue(amount, payer, currency, cashContract));
    }

    //requesting issue of Via bonds to payer (issuer) that can pay in ether, or 
    //requesting transfer of Via bonds to payer (buyer) that can pay in via cash tokens
    function issue(bytes16 amount, address payer, bytes32 currency, address cashContract) private returns(bool){
        //ensure that brought amount is not zero
        require(amount != 0);
        //adds paid in amount to the paid in currency's cash balance
        if(currency!="ether")
            if(factory.getType(cashContract)=="ViaCash")
                if(!ViaCash(address(uint160(cashContract))).requestAddToBalance(amount, payer))
                    return false;
            else
                return false;
        //call Via Oracle to fetch data for bond pricing
        if(currency=="ether"){
            //if ether is paid into a non Via-USD bond contract, the bond contract will issue bond tokens of an equivalent face value.
            //To derive the bond's face value, the exchange rate of ether to Via-USD and then to the currency paid in is applied.
            if(bondName!="Via_USD"){
                //bytes32 EthXid = oracle.request("eth","ethusd","EthBond", address(this));
                //bytes32 ViaXid = oracle.request(string(abi.encodePacked("Via_USD_to_", bondName)).stringToBytes32(),"ver","EthBond", address(this));
                //oracle.setCallbackId(EthXid,ViaXid);
                bytes32 EthXid = "11";
                bytes32 ViaXid = "22";
                conversion memory c = conversionQ[ViaXid];
                c.operation = "issue";
                c.party = payer;
                c.amount = amount;
                c.paid_in_currency = currency;
                c.EthXid = EthXid;
                c.EthXvalue = ABDKMathQuad.fromUInt(0);
                c.bond_currency = bondName;
                c.ViaXvalue =ABDKMathQuad.fromUInt(0);
                convert("22","1.2","ver");
                convert("22","451.25","ethusd");
            }
            //if ether is paid into a Via-USD bond contract, issuing the bond token will only require the ether to Via-USD exchange rate. 
            else{
                //bytes32 EthXid = oracle.request("eth","ethusd","EthBond", address(this));
                bytes32 EthXid = "11";
                conversion memory c = conversionQ[EthXid];
                c.operation = "issue";
                c.party = payer;
                c.amount = amount;
                c.paid_in_currency = currency;
                c.EthXid = EthXid;
                c.EthXvalue = ABDKMathQuad.fromUInt(0);
                c.bond_currency = bondName;
                c.ViaXvalue =ABDKMathQuad.fromUInt(1);
                convert("11","451.25","ethusd");
            }
        }
        //if a via cash token is paid into this bond contract
        else{
            //if the via cash token paid in is different from the denomination of this bond, 
            //tokens of this bond need to be transferred from an issuers' account after pricing the bond with applicable coupon rates
            if(currency!=bondName){
                //bytes32 ViaXid = oracle.request(string(abi.encodePacked(currency, "_to_", bondName)).stringToBytes32(),"er","Bond", address(this));                
                //bytes32 ViaRateId;
                //if(currency!="Via_USD"){
                //    ViaRateId = oracle.request(string(abi.encodePacked("Via_USD_to_", currency)).stringToBytes32(), "ir","Bond",address(this));
                //}
                //else{
                //    ViaRateId = oracle.request("USD", "ir","Bond",address(this));
                //}
                bytes32 ViaXid = "33";
                bytes32 ViaRateId = "44";
                conversion memory c = conversionQ[ViaXid];
                c.operation = "issue";
                c.party = payer;
                c.amount = amount;
                c.paid_in_currency = currency;
                c.bond_currency = bondName;
                c.ViaXvalue =ABDKMathQuad.fromUInt(0);
                c.ViaRateId = ViaRateId; 
                c.ViaRateValue = ABDKMathQuad.fromUInt(0);
                convert("33","7.6","er");
                convert("33","1.5","ir");
            }
            //if the via cash token paid in is the same denomination of this bond, we need to first find out if the pay in is for a purchase of bonds or repayment of an earlier issue
            else{
                bool found = false;
                for(uint256 q=0; q<bondsIssued.length; q++){
                    if(ABDKMathQuad.cmp(issues[payer][bondsIssued[q]].parValue, amount)==0 &&
                        issues[payer][bondsIssued[q]].counterParties[0]!=payer){
                        //if the paying in is for repayment of a bond already issued, then
                        //transfer the paid in amount to the bond holders, release the collateral back to the issuer and extinguish the bond
                        found = true;
                        if(!redeem(amount, payer, currency, "ViaCash"))
                            return false;
                    }
                }
                //if the paying in is not for repayment of a bond already issued, then
                //tokens of this bond need to be transferred from an issuer's account after pricing the bond with the domestic (paid in currency) coupon rates
                if(!found){
                    //bytes32 ViaRateId = oracle.request(currency, "ir","Bond",address(this));
                    bytes32 ViaRateId = "44";
                    conversion memory c = conversionQ[ViaRateId];
                    c.operation = "issue";
                    c.party = payer;
                    c.amount = amount;
                    c.paid_in_currency = currency;
                    c.bond_currency = bondName;
                    c.ViaXvalue =ABDKMathQuad.fromUInt(1);
                    c.ViaRateId = ViaRateId; 
                    c.ViaRateValue = ABDKMathQuad.fromUInt(0);
                    convert("44","1.5","ir");
                }                
            }
        }
        return true;
    }

    //requesting redemption of Via bonds and transfer of ether or via cash collateral to issuer 
    function redeem(bytes16 amount, address payer, bytes32 tokenName, bytes32 tokenType) private returns(bool){
        //if Via bond holder redeems bond on day of expiry, issuer collateral is transferred to bond holder
        if(tokenType=="ViaBond"){
            bool status = false;
            //find if the bond was issued to payer (purchaser) earlier
            for(uint256 q=0; q<bondsIssued.length; q++){
                if(ABDKMathQuad.cmp(purchases[payer][bondsIssued[q]].purchasedIssueAmount, amount)==0){
                    for(uint256 p=0; p<issues[purchases[payer][bondsIssued[q]].counterParties[0]][bondsIssued[q]].counterParties.length; p++){
                        if(payer==issues[purchases[payer][bondsIssued[q]].counterParties[0]][bondsIssued[q]].counterParties[p]){
                            //calculate redemption amount based on duration of holding by bond subscriber
                            uint256 subscribedDays = (purchases[payer][bondsIssued[q]].timeSubscribed - now)/ 60 / 60 / 24;
                            bytes16 redemptionAmount = ABDKMathQuad.mul(ABDKMathQuad.mul(ABDKMathQuad.div(purchases[payer][bondsIssued[q]].parValue, purchases[payer][bondsIssued[q]].price), 
                                                        ABDKMathQuad.div(ABDKMathQuad.fromUInt(subscribedDays),ABDKMathQuad.fromUInt(365))), purchases[payer][bondsIssued[q]].purchasedIssueAmount);
                            require(!lock);
                            lock = true;
                            //if collateral is ether, transfer ether from issuer to purchaser (redeemer) of bond
                            if(purchases[payer][bondsIssued[q]].collateralCurrency=="ether"){
                                //adjust total supply of this via bond
                                ViaToken(bondsIssued[q]).reduceSupply(amount);
                                //reduce payer's balance of bond held
                                ViaToken(bondsIssued[q]).reduceBalance(payer, amount);
                                //send redeemed ether to payer
                                address(uint160(payer)).transfer(ABDKMathQuad.toUInt(redemptionAmount));
                                //generate event
                                emit ViaBondRedeemed(tokenName, ABDKMathQuad.toUInt(redemptionAmount), ABDKMathQuad.toUInt(purchases[payer][bondsIssued[q]].purchasedIssueAmount), subscribedDays);
                                status = true;
                                delete(purchases[payer][bondsIssued[q]]);
                                delete(issues[payer][bondsIssued[q]].counterParties[p]);
                                lock = false;
                                break;
                            }
                            else    
                                lock = false;                        
                        }
                    }
                }
            }
            //find if the bond was issued to payer (issuer) earlier
            for(uint256 q=0; q<bondsIssued.length; q++){
                if(ABDKMathQuad.cmp(ABDKMathQuad.sub(issues[payer][bondsIssued[q]].parValue, issues[payer][bondsIssued[q]].purchasedIssueAmount), amount)==0){
                    require(!lock);
                    lock = true;
                    //calculate redemption amount based on how much collateral is not encumbered
                    uint256 issuedDays = (issues[payer][bondsIssued[q]].timeSubscribed - now)/ 60 / 60 / 24;
                    bytes16 uncumberedAmount = ABDKMathQuad.sub(issues[payer][bondsIssued[q]].parValue, issues[payer][bondsIssued[q]].purchasedIssueAmount);
                    //if collateral is ether, transfer ether from issuer to issuer (redeemer) of bond
                    if(issues[payer][bondsIssued[q]].collateralCurrency=="ether"){
                        //adjust total supply of this via bond
                        ViaToken(bondsIssued[q]).reduceSupply(amount);
                        //reduce payer's balance of bond held
                        ViaToken(bondsIssued[q]).reduceBalance(payer, amount);
                        //send redeemed ether to payer
                        address(uint160(payer)).transfer(ABDKMathQuad.toUInt(uncumberedAmount));
                        //generate event
                        emit ViaBondRedeemed(tokenName, ABDKMathQuad.toUInt(uncumberedAmount), ABDKMathQuad.toUInt(amount), issuedDays);
                        status = true;
                        lock = false;
                    }
                    if(status && ABDKMathQuad.cmp(issues[payer][bondsIssued[q]].collateralAmount, amount)==0){
                        //if bond is redeemed in full by issuer, then remove issue from list of issues
                        delete(issues[payer][bondsIssued[q]]);
                    }
                    else{
                        //else, if bond is redeemed partially by issuer, then adjust redeemed amount with collateral balance in purchaser accounts
                        for(uint256 p=0; p<issues[payer][bondsIssued[q]].counterParties.length; p++){
                            purchases[issues[payer][bondsIssued[q]].counterParties[p]][bondsIssued[q]].collateralAmount = 
                            ABDKMathQuad.sub(purchases[issues[payer][bondsIssued[q]].counterParties[p]][bondsIssued[q]].collateralAmount, uncumberedAmount);
                        }
                    }   
                    break;                 
                }
            }
            return status;
        }
        //if Via bond issuer pays in cash for redemption, it is paid back to Via bond holders and collateral paid back to issuers
        else{
            address viaAddress;
            bool status = false;
            bytes16 totalToRedeem;
            //find the bond that was issued by payer (issuer) earlier
            for(uint256 q=0; q<bondsIssued.length; q++){
                if(ABDKMathQuad.cmp(amount, issues[payer][bondsIssued[q]].purchasedIssueAmount)==1){
                    for(uint256 p=0; p<issues[payer][bondsIssued[q]].counterParties.length; p++){
                        status = false;
                        address cp = issues[payer][bondsIssued[q]].counterParties[p];
                        //if collateral is ether, release collateral and transfer ether to issuer of bond
                        //and send paid in amount to purchaser of bond
                        if(issues[payer][bondsIssued[q]].collateralCurrency=="ether"){
                            //calculate redemption amount based on duration of holding by bond subscriber
                            uint256 subscribedDays = (purchases[cp][bondsIssued[q]].timeSubscribed - now)/ 60 / 60 / 24;
                            bytes16 redemptionAmount = ABDKMathQuad.mul(ABDKMathQuad.mul(ABDKMathQuad.div(purchases[cp][bondsIssued[q]].parValue, 
                                                        purchases[cp][bondsIssued[q]].price), 
                                                        ABDKMathQuad.div(ABDKMathQuad.fromUInt(subscribedDays),ABDKMathQuad.fromUInt(365))), 
                                                        purchases[cp][bondsIssued[q]].purchasedIssueAmount);
                            require(!lock);
                            lock = true;
                            //if amount available for redemption is more or equal to redemption amount for the purchaser
                            if(amount >= redemptionAmount){
                                //send paid in amount to bond purchaser
                                viaAddress = factory.getIssuer("ViaCash", tokenName);
                                if(viaAddress!=address(0x0)){
                                    bytes16 balanceToRedeem = ViaCash(address(uint160(viaAddress))).requestDeductFromBalance(redemptionAmount, cp);
                                    //adjust total supply of this via bond
                                    ViaToken(bondsIssued[q]).reduceSupply(redemptionAmount);     
                                    //reduce counter party's balance of bond held
                                    ViaToken(bondsIssued[q]).reduceBalance(cp, redemptionAmount);
                                    totalToRedeem = ABDKMathQuad.add(totalToRedeem, balanceToRedeem);
                                    //if balance left to redeem is 0
                                    if(balanceToRedeem==0){
                                        //adjust amount available for redemption 
                                        amount = ABDKMathQuad.sub(amount, redemptionAmount);
                                        //generate event
                                        emit ViaBondRedeemed(tokenName, ABDKMathQuad.toUInt(redemptionAmount), ABDKMathQuad.toUInt(purchases[cp][bondsIssued[q]].purchasedIssueAmount), subscribedDays);
                                        status = true; 
                                    }
                                    else{
                                        //adjust amount available for redemption 
                                        amount = ABDKMathQuad.sub(amount, ABDKMathQuad.sub(redemptionAmount, balanceToRedeem));
                                        //generate event
                                        emit ViaBondRedeemed(tokenName, ABDKMathQuad.toUInt(balanceToRedeem), ABDKMathQuad.toUInt(purchases[cp][bondsIssued[q]].purchasedIssueAmount), subscribedDays);
                                    }
                                }
                                lock = false;
                            }
                            else
                                lock = false;  
                        }
                        if(status)
                            //if a purchaser is redeemed, then delete its record from list of purchases
                            delete(purchases[cp][bondsIssued[q]]);
                        if(p==issues[payer][bondsIssued[q]].counterParties.length-1)
                            //if all bond purchasers are redeemed, then delete the issuer record
                            delete(issues[payer][bondsIssued[q]]);
                    }
                    if(status){
                        //find proportion to redeem
                        bytes16 proportionToRedeem = ABDKMathQuad.div(totalToRedeem, issues[payer][bondsIssued[q]].purchasedIssueAmount);
                        //returned redeemed proportion of collateral to payer (issuer)
                        bytes16 etherToRedeem = ABDKMathQuad.mul(issues[payer][bondsIssued[q]].collateralAmount, ABDKMathQuad.sub(ABDKMathQuad.fromUInt(1), proportionToRedeem));
                        //send redeemed ether to payer
                        address(uint160(payer)).transfer(ABDKMathQuad.toUInt(etherToRedeem));   
                        //if any balance amount remains after redemptions, return the balance to the issuer
                        if(amount>0){
                            address(uint160(payer)).transfer(ABDKMathQuad.toUInt(amount));
                        }
                    }
                    break;
                }
            }
            return status;
        }
    }

    //function called back from Oraclize
    function convert(bytes32 txId, bytes16 result, bytes32 rtype) public {
        //require(viaoracle == msg.sender);
        //check type of result returned
        if(rtype =="ethusd"){
            conversionQ[txId].EthXvalue = result;
        }
        if(rtype == "ir"){
            conversionQ[txId].ViaRateValue = result;
        }
        if(rtype == "er"){
            conversionQ[txId].EthXvalue = result;
        }
        if(rtype == "ver"){
            conversionQ[txId].ViaXvalue = result;
        }
        //check if bond needs to be issued
        if(conversionQ[txId].operation=="issue"){
            if(rtype == "ethusd" || rtype == "ver"){
                if(ABDKMathQuad.cmp(conversionQ[txId].EthXvalue, ABDKMathQuad.fromUInt(0))!=0 &&
                    ABDKMathQuad.cmp(conversionQ[txId].ViaXvalue, ABDKMathQuad.fromUInt(0))!=0){
                    //calculate par value of via bond by applying exchange rates from via oracle    
                    bytes16 parValue = convertToVia(conversionQ[txId].amount, conversionQ[txId].paid_in_currency,conversionQ[txId].EthXvalue,conversionQ[txId].ViaXvalue);
                    //calculate price of via bond by applying interest rates from via oracle
                    bytes16 viaBondPrice = ABDKMathQuad.div(parValue, ABDKMathQuad.add(ABDKMathQuad.fromUInt(1), ABDKMathQuad.fromUInt(0)))^ABDKMathQuad.fromUInt(1);
                    //issue bond to issuer
                    finallyIssue(conversionQ[txId].party, parValue, viaBondPrice, conversionQ[txId].amount, conversionQ[txId].paid_in_currency);
                }
            }
            else if(rtype == "er" || rtype =="ir"){
                if(ABDKMathQuad.cmp(conversionQ[txId].ViaXvalue, ABDKMathQuad.fromUInt(0))!=0 && 
                    ABDKMathQuad.cmp(conversionQ[txId].ViaRateValue, ABDKMathQuad.fromUInt(0))!=0){
                    //calculate par value of via bond by applying exchange rates from via oracle
                    bytes16 parValue = convertToVia(conversionQ[txId].amount, conversionQ[txId].paid_in_currency,conversionQ[txId].EthXvalue,conversionQ[txId].ViaXvalue);
                    //calculate price of via bond by applying interest rates from via oracle
                    bytes16 viaBondPrice = ABDKMathQuad.div(parValue, ABDKMathQuad.add(ABDKMathQuad.fromUInt(1), conversionQ[txId].ViaRateValue))^ABDKMathQuad.fromUInt(1);
                    //transfer bond from issuer to purchaser, and transfer paid in cash token from purchaser to issuer
                    finallyIssue(conversionQ[txId].party, parValue, viaBondPrice, conversionQ[txId].amount, conversionQ[txId].paid_in_currency);
                }
            }
        }
    }

    //issue bond tokens if ether is paid in, or transfer bond tokens if via cash tokens are paid in
    function finallyIssue(address payer, bytes16 parValue, bytes16 bondPrice, bytes16 paidInAmount, bytes32 paidInCashToken) private {
        bool found = false;
        if(paidInCashToken=="ether"){
            require(!lock);
            lock = true;
            uint256 issueTime = now;
            //issue bond which initializes a token with the attributes of the bond
            address issuedBond = factory.createToken(token, bondName, "ViaBond", string(abi.encodePacked(address(this),issueTime)).stringToBytes32());
            //adjust issued bonds to total supply first
            ViaToken(issuedBond).addTotalSupply(parValue);
            //first, add bond balance
            ViaToken(issuedBond).addBalance(issuedBond, parValue);
            //issue bond to payer if ether is paid in as collateral
            if(ViaToken(issuedBond).requestTransfer(payer, ABDKMathQuad.toUInt(parValue))){    
                //keep track of issues
                storeBond("issue", payer, payer, parValue, bondPrice, ABDKMathQuad.fromUInt(0), paidInAmount, paidInCashToken, issueTime, issuedBond);
                bondsIssued.push(issuedBond);
                //keep track of issuers
                for(uint256 i=0; i<issuers.length; i++){
                    if(issuers[i]==payer){
                        found = true;
                        break;
                    }
                }
                if(!found)
                    issuers.push(payer);
                lock = false;
            }
            else
                lock = false;
        }
        //paid in amount is Via cash
        else{
            for(uint256 i=0; i<issuers.length; i++){
                for(uint256 q=0; q<bondsIssued.length; q++){
                    //check if there are enough issued bonds to be purchased
                    if(ABDKMathQuad.cmp(ABDKMathQuad.sub(issues[issuers[i]][bondsIssued[q]].parValue, issues[issuers[i]][bondsIssued[q]].purchasedIssueAmount), paidInAmount)==0 ||
                        ABDKMathQuad.cmp(ABDKMathQuad.sub(issues[issuers[i]][bondsIssued[q]].parValue, issues[issuers[i]][bondsIssued[q]].purchasedIssueAmount), paidInAmount)==1){
                        require(!lock);
                        lock = true;
                        //if there is enough issued bonds, transfer bond from issuer to payer
                        if(ViaToken(bondsIssued[q]).requestTransfer(payer, ABDKMathQuad.toUInt(paidInAmount))){
                            //transfer cash paid in by purchaser to issuer from whom bond is transferred to purchaser
                            address viaAddress = factory.getIssuer("ViaCash", paidInCashToken);
                            if(viaAddress!=address(0x0)){
                                //deduct paid out cash token from purchaser cash balance
                                ViaCash(address(uint160(viaAddress))).transferFrom(payer, issuers[i], ABDKMathQuad.toUInt(paidInAmount));
                                //add purchaser as counter party in issuer's record
                                if(issues[issuers[i]][bondsIssued[q]].counterParties.length==1)
                                    issues[issuers[i]][bondsIssued[q]].counterParties[0] = payer;
                                else
                                    issues[issuers[i]][bondsIssued[q]].counterParties[issues[issuers[i]][bondsIssued[q]].counterParties.length] = payer;
                                //reduce issuable value of bond by amount transferred to purchaser
                                issues[issuers[i]][bondsIssued[q]].purchasedIssueAmount = ABDKMathQuad.add(issues[issuers[i]][bondsIssued[q]].purchasedIssueAmount, paidInAmount); 
                                //add bond to purchaser's record
                                storeBond("purchase", payer, issuers[i], parValue, bondPrice, issues[issuers[i]][bondsIssued[q]].purchasedIssueAmount, paidInAmount, paidInCashToken, now, bondsIssued[q]);
                                lock = false;
                                break;
                            }
                            else
                                lock = false;         
                        }
                        else
                            lock = false;
                    }
                }
            }    
        }
        //generate event
        emit ViaBondIssued(bondName, ABDKMathQuad.toUInt(parValue), ABDKMathQuad.toUInt(paidInAmount), 1);
    }

    //convert given currency and amount to via cash token
    function convertToVia(bytes16 amount, bytes32 currency, bytes16 ethusd, bytes16 viarate) private view returns(bytes16){
        if(currency=="ether"){
            //to first convert amount of ether passed to this function to USD
            bytes16 amountInUSD = ABDKMathQuad.mul(ABDKMathQuad.div(amount, ABDKMathQuad.fromUInt(1000000000000000000)), ethusd);
            //to then convert USD to Via-currency if currency of this contract is not USD itself
            if(bondName!="Via_USD"){
                bytes16 inVia = ABDKMathQuad.mul(amountInUSD, viarate);
                return inVia;
            }
            else{
                return amountInUSD;
            }
        }
        //if currency paid in another via currency
        else{
            bytes16 inVia = ABDKMathQuad.mul(amount, viarate);
            return inVia;
        }
    }

    //stores issued and purchased bond details
    function storeBond( bytes32 _operation,
                        address _payer,
                        address _party,
                        bytes16 _parValue,
                        bytes16 _bondPrice,
                        bytes16 _purchasedIssueAmount,
                        bytes16 _paidInAmount,
                        bytes32 _paidInCashToken,
                        uint256 _timeIssued,
                        address _issuedBond) private {
        if(_operation=="issue"){
            issues[_payer][_issuedBond].counterParties[0] = _party;
            issues[_payer][_issuedBond].parValue = _parValue;
            issues[_payer][_issuedBond].price = _bondPrice;
            issues[_payer][_issuedBond].purchasedIssueAmount = _purchasedIssueAmount;
            issues[_payer][_issuedBond].collateralAmount = _paidInAmount;
            issues[_payer][_issuedBond].collateralCurrency = _paidInCashToken;
            issues[_payer][_issuedBond].timeSubscribed = _timeIssued;
        }
        else if(_operation=="purchase"){
            purchases[_payer][_issuedBond].counterParties[0] = _party;
            purchases[_payer][_issuedBond].parValue = _parValue;
            purchases[_payer][_issuedBond].price = _bondPrice;
            purchases[_payer][_issuedBond].purchasedIssueAmount = _purchasedIssueAmount;
            purchases[_payer][_issuedBond].collateralAmount = _paidInAmount;
            purchases[_payer][_issuedBond].collateralCurrency = _paidInCashToken;
            purchases[_payer][_issuedBond].timeSubscribed = _timeIssued;
        }
    }

}
