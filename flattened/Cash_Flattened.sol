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

// File: contracts/Cash.sol

// (c) Kallol Borah, 2020
// Implementation of the Via cash token.

pragma solidity >=0.5.0 <0.7.0;










contract Cash is ViaCash, ERC20, Initializable, Ownable {

    using stringutils for *;

    using ABDKMathQuad for uint256;
    using ABDKMathQuad for int256;
    using ABDKMathQuad for bytes16;

    //via factory address
    ViaFactory private factory;

    //via oracle
    Oracle private oracle;
    address viaoracle;

    //name of Via cash token (eg, Via-USD)
    string public name;
    string public symbol;
    bytes32 public cashtokenName;

    //mapping of buyers (address) to currency (bytes32) to deposit (bytes16) amounts they make against which via cash tokens are issued
    mapping(address => mapping(bytes32 => bytes16)) public deposits;

    //data structure holding details of currency conversion requests pending on oraclize
    struct conversion{
        address party;
        address counterparty;
        bytes32 operation;
        bytes32 paid_in_currency;
        bytes32 payout_currency;
        bytes32 EthXid;
        bytes16 amount;
        bytes16 EthXvalue;
        bytes16 ViaXvalue;
    }

    //queue of pending conversion requests with each pending request mapped to a request_id returned by oraclize
    mapping(bytes32 => conversion) private conversionQ;

    //events to capture and report to Via oracle
    event ViaCashIssued(bytes32 currency, bytes16 value);
    event ViaCashRedeemed(bytes32 currency, bytes16 value);
    event LogCallback(bytes32 EthXid, bytes16 EthXvalue, bytes32 txId, bytes16 ViaXvalue);

    //mutex
    bool lock;

    //initiliaze proxies
    function initialize(bytes32 _name, bytes32 _type, address _owner, address _oracle, address _token) public initializer{
        Ownable.initialize(_owner);
        factory = ViaFactory(_owner);
        oracle = Oracle(_oracle);
        viaoracle = _oracle;
        name = string(abi.encodePacked(_name));
        symbol = string(abi.encodePacked(_type));
        cashtokenName = _name;
        lock = false;
        decimals = 2;
    }

    //handling pay in of ether for issue of via cash tokens
    function() external payable{
        //ether paid in
        require(msg.value !=0);
        //only to pay in ether
        require(msg.data.length==0);
        //issue via cash tokens
        issue(ABDKMathQuad.fromUInt(msg.value), msg.sender, "ether");
    }

    //overriding this function of ERC20 standard for transfer of via cash tokens to other users or to this contract for redemption
    function transferFrom(address sender, address receiver, uint256 tokens) external returns (bool){
        //ensure sender has enough tokens in balance before transferring or redeeming them
        require(ABDKMathQuad.cmp(balances[sender],ABDKMathQuad.fromUInt(tokens))!=-1);// || 
                //ABDKMathQuad.cmp(balances[sender],ABDKMathQuad.fromUInt(tokens))==0);
        //check if tokens are being transferred to this cash contract
        if(receiver == address(this)){
            //if token name is the same, this transfer has to be redeemed
            if(redeem(ABDKMathQuad.fromUInt(tokens), sender, cashtokenName, "redeem", address(this)))
                return true;
            else
                return false;
        }
        //else request issue of cash tokens requested from receiver
        else if(factory.getType(receiver)=="ViaCash"){
            //only issue if cash tokens are paid in, since bond tokens can't be paid to issue bond token
            if(Cash(address(uint160(receiver))).requestIssue(ABDKMathQuad.fromUInt(tokens), sender, cashtokenName)){
                require(!lock);
                lock = true;
                balances[sender] = ABDKMathQuad.sub(balances[sender], ABDKMathQuad.fromUInt(tokens));
                //adjust total supply
                totalSupply_ = ABDKMathQuad.sub(totalSupply_, ABDKMathQuad.fromUInt(tokens));
                lock = false; 
                return true;                
            }
            else
                return false;
        }
        //else if cash tokens are paid into bond issuers, then request for issue of bonds
        else if(factory.getType(receiver)=="ViaBond"){
            if(ViaBond(address(uint160(receiver))).requestIssue(ABDKMathQuad.fromUInt(tokens), sender, cashtokenName, address(this)))
                    return true;
                else
                    return false;
        }
        else{
            //else, tokens are being sent to another user's account
            //sending contract should be allowed by token owner to make this transfer
            //allowed[sender][msg.sender] = ABDKMathQuad.sub(allowed[sender][msg.sender], ABDKMathQuad.fromUInt(tokens));
            //if(transferToken(sender, receiver, tokens)){
            if(redeem(ABDKMathQuad.fromUInt(tokens), sender, cashtokenName, "transfer", receiver)){
                emit Transfer(sender, receiver, tokens);
                return true;
            }
            else
                return false;
        }
    }

    //accessor for addToBalance function
    function requestAddToBalance(bytes16 tokens, address sender) external returns (bool){
        require(factory.getType(msg.sender) == "ViaCash" || factory.getType(msg.sender) == "ViaBond");
        return(addToBalance(tokens, sender));
    }

    //add to token balance of this contract from token balance of sender
    function addToBalance(bytes16 tokens, address sender) private returns (bool){
        //sender should have more tokens than being transferred
        if(ABDKMathQuad.cmp(tokens, balances[sender])==-1 || ABDKMathQuad.cmp(tokens, balances[sender])==0){
            balances[sender] = ABDKMathQuad.sub(balances[sender], tokens);
            balances[address(this)] = ABDKMathQuad.add(balances[address(this)], tokens);
            return true;
        }
        else
            return false;
    }

    //accessor for deductFromBalance function
    function requestDeductFromBalance(bytes16 tokens, address receiver) external returns (bytes16){
        require(factory.getType(msg.sender) == "ViaCash" || factory.getType(msg.sender) == "ViaBond");
        return(deductFromBalance(tokens, receiver));
    }

    //deduct token balance from this contract and add token balance to receiver
    function deductFromBalance(bytes16 tokens, address receiver) private returns (bytes16){
        //this cash token issuer should have more tokens than being deducted
        if(ABDKMathQuad.cmp(tokens, balances[address(this)])==-1 || ABDKMathQuad.cmp(tokens, balances[address(this)])==0){
            balances[address(this)] = ABDKMathQuad.sub(balances[address(this)], tokens);
            balances[receiver] = ABDKMathQuad.add(balances[receiver], tokens);
            emit Transfer(address(this), receiver, ABDKMathQuad.toUInt(tokens)); 
            return ABDKMathQuad.fromUInt(0);
        }
        else{
            bytes16 balance = ABDKMathQuad.sub(tokens, balances[address(this)]);
            balances[receiver] = ABDKMathQuad.add(balances[receiver], balances[address(this)]);
            emit Transfer(address(this), receiver, ABDKMathQuad.toUInt(balances[address(this)]));
            balances[address(this)] = 0;            
            return balance;
        }
    }

    //accessor for issue function
    function requestIssue(bytes16 amount, address buyer, bytes32 currency) public returns(bool){
        require(factory.getType(msg.sender) == "ViaCash");
        return(issue(amount, buyer, currency));
    }

    //requesting issue of Via to buyer for amount of ether or some other via cash token paid in and stored in cashContract
    function issue(bytes16 amount, address buyer, bytes32 currency) private returns(bool){
        //ensure that brought amount is not zero
        require(amount != 0);
        //find amount of via cash tokens to transfer after applying exchange rate
        if(currency=="ether"){
            //if ether is paid in for issue of Via-USD cash token, then all we need is the exchange rate of ether to USD (ethusd)
            //since the exchange rate of USD to Via-USD is always 1
            if(cashtokenName=="Via_USD"){
                bytes32 EthXid = oracle.request("eth","ethusd","EthCash", address(this)); 
                //bytes32 EthXid = "11";
                conversionQ[EthXid] = conversion(buyer, address(0x0), "issue", currency, cashtokenName, EthXid, amount, ABDKMathQuad.fromUInt(0), ABDKMathQuad.fromUInt(1));
                //convert("11",ABDKMathQuad.fromUInt("451.25".stringToUint()),"ethusd");
            }
            //if ether is paid in for issue of non-USD cash token, we need the exchange rate of ether to the USD (ethusd)
            //and the exchange rate of Via-USD to the requested non-USD cash token (eg, Via-EUR)
            else{
                bytes32 ViaXid = oracle.request(string(abi.encodePacked("Via_USD_to_", cashtokenName)).stringToBytes32(),"ver","Cash", address(this)); 
                bytes32 EthXid = oracle.request("eth","ethusd","EthCash", address(this)); 
                oracle.setCallbackId(EthXid,ViaXid);
                //bytes32 EthXid = "11";
                //bytes32 ViaXid = "22";
                conversionQ[ViaXid] = conversion(buyer, address(0x0), "issue", currency, cashtokenName, EthXid, amount, ABDKMathQuad.fromUInt(0), ABDKMathQuad.fromUInt(0));
                //convert("22",ABDKMathQuad.fromUInt("451.25".stringToUint()),"ethusd");
                //convert("22",ABDKMathQuad.fromUInt("1.2".stringToUint()),"ver");                
            }
        }
        //if ether is not paid in and instead, some other Via cash token is paid in
        //we need to find the exchange rate between the paid in Via cash token and the cash token this cash contract represents
        else{
            bytes32 ViaXid = oracle.request(string(abi.encodePacked(currency, "_to_", cashtokenName)).stringToBytes32(),"er","Cash", address(this)); 
            //bytes32 ViaXid = "33";
            conversionQ[ViaXid] = conversion(buyer, address(0x0), "issue", currency, cashtokenName, ABDKMathQuad.fromUInt(0), amount, ABDKMathQuad.fromUInt(0), ABDKMathQuad.fromUInt(0));
            //convert("33",ABDKMathQuad.fromUInt("7.6".stringToUint()),"er");
        }
        return true;
    }

    //requesting redemption of Via cash token and transfer of currency it was issued against
    //operation parameter indicates whether it is a redemption or a transfer of deposits from one party to another
    function redeem(bytes16 amount, address seller, bytes32 token, bytes32 operation, address receiver) private returns(bool){
        //if amount is not zero, there is some left to redeem
        if(amount != 0){
            bytes32 currency_in_deposit="";
            //find currency that seller had deposited earlier
            for(uint256 q=0; q<factory.getTokenCount(); q++){
                address viaAddress = factory.getToken(q);
                (bytes32 tname, bytes32 ttype) = factory.getNameAndType(viaAddress);
                if(ttype == "ViaCash" && deposits[seller][tname]>0){
                    currency_in_deposit = tname;
                    break;
                }
            }
            //if no more currencies to redeem and amount to redeem is not zero, then redemption fails
            if(currency_in_deposit=="" && deposits[seller]["ether"]>0)
                currency_in_deposit = "ether";
            //if currency that this cash token can be redeemed in is ether
            if(currency_in_deposit=="ether"){
                //if the cash token to redeem is a Via USD, all we need is the exchange rate of ether to the USD
                if(token=="Via_USD"){
                    bytes32 EthXid = oracle.request("eth","ethusd","Cash", address(this)); 
                    //bytes32 EthXid = "11";
                    conversionQ[EthXid] = conversion(seller, receiver, operation, token, currency_in_deposit, EthXid, amount, ABDKMathQuad.fromUInt(0), ABDKMathQuad.fromUInt(1));
                    //convert("11",ABDKMathQuad.fromUInt("451.25".stringToUint()),"ethusd");
                }
                //and if cash token to redeem is not Via USD, we need to get the exchange rate of ether to the Via-USD, 
                //and then the exchange rate of this Via cash token to redeeem and the Via-USD
                else{
                    bytes32 EthXid = oracle.request("eth","ethusd","EthCash", address(this)); 
                    bytes32 ViaXid = oracle.request(string(abi.encodePacked(token, "_to_Via_USD")).stringToBytes32(),"ver","Cash", address(this)); 
                    oracle.setCallbackId(EthXid,ViaXid);
                    //bytes32 EthXid = "11";
                    //bytes32 ViaXid = "22";
                    conversionQ[ViaXid] = conversion(seller, receiver, operation, token, currency_in_deposit, EthXid, amount, ABDKMathQuad.fromUInt(0), ABDKMathQuad.fromUInt(0));
                    //convert("22",ABDKMathQuad.fromUInt("451.25".stringToUint()),"ethusd");
                    //convert("22",ABDKMathQuad.fromUInt("1.2".stringToUint()),"ver");
                }
            }
            //else if the currency this cash token can be redeemed is another Via cash token,
            //we just need the exchange rate of this Via cash token to redeem and the currency that is in deposit
            else{
                bytes32 ViaXid = oracle.request(string(abi.encodePacked(token, "_to_", currency_in_deposit)).stringToBytes32(),"er","Cash", address(this)); //"1234"; //only for testing
                //bytes32 ViaXid = "33";
                conversionQ[ViaXid] = conversion(seller, receiver, operation, token, currency_in_deposit, ABDKMathQuad.fromUInt(0), amount, ABDKMathQuad.fromUInt(0), ABDKMathQuad.fromUInt(0));
                //convert("33",ABDKMathQuad.fromUInt("7.6".stringToUint()),"er");
            }
        }
        else
            //redemption is complete when amount to redeem becomes zero
            return true;
    }    

    //function called back from Via oracle
    //function convert(bytes32 txId, bytes16 result, bytes32 rtype) external {
    function convert(bytes32 txId, bytes16 result, bytes32 rtype) external {
        require(viaoracle == msg.sender);
        //check type of result returned
        if(rtype =="ethusd"){
            conversionQ[txId].EthXvalue = result;
        }
        if(rtype == "er"){
            conversionQ[txId].ViaXvalue = result;
        }
        if(rtype == "ver"){
            conversionQ[txId].ViaXvalue = result;
        }
        //check if cash needs to be issued or redeemed
        if(conversionQ[txId].operation=="issue"){
            if(rtype == "ethusd" || rtype == "ver"){
                emit LogCallback(conversionQ[txId].EthXid, conversionQ[txId].EthXvalue, txId, conversionQ[txId].ViaXvalue);
                //for issuing to happen when ether is paid in,
                //value of ethX (ie ether exchange rate to USD) has to be non-zero 
                //and viaX (ie via exchange) should be non-zero if cash token to be issued is not Via-USD. We store 1 for ViaXvalue if Via-USD has to be issued
                if(ABDKMathQuad.cmp(conversionQ[txId].EthXvalue, ABDKMathQuad.fromUInt(0))!=0 && ABDKMathQuad.cmp(conversionQ[txId].ViaXvalue, ABDKMathQuad.fromUInt(0))!=0){
                    bytes16 via = convertToVia(conversionQ[txId].amount, conversionQ[txId].paid_in_currency,conversionQ[txId].EthXvalue,conversionQ[txId].ViaXvalue);
                    finallyIssue(via, conversionQ[txId].party, conversionQ[txId].paid_in_currency, conversionQ[txId].amount);
                }
            }
            else if(rtype == "er"){
                //for issuing to happen if some other Via cash token is paid in, 
                //only the value of ViaX (ie exchange rate of paid in Via cash token to Via cash token to issue) has to be non-zero
                if(ABDKMathQuad.cmp(conversionQ[txId].ViaXvalue, ABDKMathQuad.fromUInt(0))!=0){
                    bytes16 via = convertToVia(conversionQ[txId].amount, conversionQ[txId].paid_in_currency,conversionQ[txId].EthXvalue,conversionQ[txId].ViaXvalue);
                    finallyIssue(via, conversionQ[txId].party, conversionQ[txId].paid_in_currency, conversionQ[txId].amount);
                }
            }
        }
        else if(conversionQ[txId].operation=="redeem" || conversionQ[txId].operation=="transfer"){
            if(rtype == "ethusd" || rtype == "ver"){
                //for redemption to happen in ether,
                //value of ethX (ie ether exchange rate to USD) has to be non-zero 
                //and viaX (ie via exchange) should be non-zero if cash token to be redeemed is not Via-USD. We store 1 for ViaXvalue if Via-USD has to be redeemed
                if(ABDKMathQuad.cmp(conversionQ[txId].EthXvalue, ABDKMathQuad.fromUInt(0))!=0 && ABDKMathQuad.cmp(conversionQ[txId].ViaXvalue, ABDKMathQuad.fromUInt(0))!=0){
                    bytes16 value = convertFromVia(conversionQ[txId].amount, conversionQ[txId].payout_currency,conversionQ[txId].EthXvalue,conversionQ[txId].ViaXvalue);
                    finallyRedeem(value, conversionQ[txId].payout_currency, conversionQ[txId].party, conversionQ[txId].amount, conversionQ[txId].operation, conversionQ[txId].counterparty);
                }
            }
            else if(rtype == "er"){
                //for redemption to happen in some other Via cash token
                //the viaX (ie via exchange rate) between the cash token to redeem and the cash token in deposit should be non-zero
                if(ABDKMathQuad.cmp(conversionQ[txId].ViaXvalue, ABDKMathQuad.fromUInt(0))!=0){
                    bytes16 value = convertFromVia(conversionQ[txId].amount, conversionQ[txId].payout_currency,conversionQ[txId].EthXvalue,conversionQ[txId].ViaXvalue);
                    finallyRedeem(value, conversionQ[txId].payout_currency, conversionQ[txId].party, conversionQ[txId].amount, conversionQ[txId].operation, conversionQ[txId].counterparty);
                }
            }
        }
    }

    //via is the number of this via cash token that is being issued, party is the user account address to which issued tokens are credited
    function finallyIssue(bytes16 via, address party, bytes32 currency, bytes16 amount) private {
        //add paid in currency to depositor
        if(deposits[party][currency]==0){
            deposits[party][currency] = amount;
        }
        else{
            deposits[party][currency] = ABDKMathQuad.add(deposits[party][currency], amount);
        }
        //add via to this contract's balance first (ie issue them first)
        balances[address(this)] = ABDKMathQuad.add(balances[address(this)], via);
        //transfer amount to buyer 
        transfer(party, ABDKMathQuad.toUInt(via));
        //adjust total supply
        totalSupply_ = ABDKMathQuad.add(totalSupply_, via);
       //generate event
        emit Transfer(address(this), party, ABDKMathQuad.toUInt(via));
        emit ViaCashIssued(cashtokenName, via);
    }

    //value is the redeemable amount in the currency to pay out
    //currency is the pay out currency or currency to pay out
    //party is the user account address to which redemption has to be credited
    //amount is the number of this via cash token that needs to be redeemed
    function finallyRedeem(bytes16 value, bytes32 currency, address party, bytes16 amount, bytes32 operation, address receiver) private {
        //check if currency in which redemption is to be done has sufficient balance
        if(currency=="ether"){
            if(ABDKMathQuad.cmp(deposits[party]["ether"], value)==1 || ABDKMathQuad.cmp(deposits[party]["ether"], value)==0){
                deposits[party]["ether"] = ABDKMathQuad.sub(deposits[party]["ether"], value);
                //reduces balances
                balances[party] = ABDKMathQuad.sub(balances[party], amount);
                if(operation=="redeem"){
                    //adjust total supply
                    totalSupply_ = ABDKMathQuad.sub(totalSupply_, amount);
                    //send redeemed ether to party
                    address(uint160(party)).transfer(ABDKMathQuad.toUInt(value));
                    //generate event
                    emit ViaCashRedeemed(currency, value);
                }
                else if(operation=="transfer"){
                    //transfer balances
                    balances[receiver] = ABDKMathQuad.add(balances[receiver], amount);
                    //transfer deposits
                    deposits[receiver]["ether"] = ABDKMathQuad.add(deposits[receiver]["ether"], value);                    
                }
            }
            //amount to redeem is more than what is in deposit, so we need to remove deposit after redemption,
            //and call the redeem function again for the balance amount that is not yet redeemed
            else{
                bytes16 proportionRedeemed = ABDKMathQuad.div(deposits[party]["ether"], value);
                bytes16 balanceToRedeem = ABDKMathQuad.mul(amount,ABDKMathQuad.sub(ABDKMathQuad.fromUInt(1), proportionRedeemed));
                // get amount to send
                bytes16 amtSend = deposits[party]["ether"];
                // set deposit to 0 as security measure
                deposits[party]["ether"] = 0;
                //reduces balances
                balances[party] = ABDKMathQuad.sub(balances[party], ABDKMathQuad.mul(amount, proportionRedeemed));
                if(operation=="redeem"){
                    //adjust total supply
                    totalSupply_ = ABDKMathQuad.sub(totalSupply_, ABDKMathQuad.mul(amount, proportionRedeemed));
                    // send redeemed ether to party which is all of the ether in deposit with this user (party)
                    address(uint160(party)).transfer(ABDKMathQuad.toUInt(amtSend));
                    //generate event
                    emit ViaCashRedeemed(currency, deposits[party]["ether"]);
                }
                else if(operation=="transfer"){
                    //transfer balances
                    balances[receiver] = ABDKMathQuad.add(balances[receiver], ABDKMathQuad.mul(amount, proportionRedeemed));
                    //transfer deposits
                    deposits[receiver]["ether"] = ABDKMathQuad.add(deposits[receiver]["ether"], amtSend);
                }
                redeem(balanceToRedeem, party, cashtokenName, operation, receiver);
            }
        }
        //else currency to redeem is not ether
        else{
            for(uint256 q=0; q<factory.getTokenCount(); q++){
                address viaAddress = factory.getToken(q);
                (bytes32 tname, bytes32 ttype) = factory.getNameAndType(viaAddress);
                if(tname == currency && ttype == "ViaCash"){
                    if(ABDKMathQuad.cmp(Cash(address(uint160(viaAddress))).requestDeductFromBalance(value, party),0)==1){
                        deposits[party][currency] = ABDKMathQuad.sub(deposits[party][currency], value);
                        //reduces balances
                        balances[party] = ABDKMathQuad.sub(balances[party], amount);
                        if(operation=="redeem"){
                            //adjust total supply
                            totalSupply_ = ABDKMathQuad.sub(totalSupply_, amount);
                            //send redeemed currency to party
                            address(uint160(party)).transfer(ABDKMathQuad.toUInt(value));
                            //generate event
                            emit ViaCashRedeemed(currency, value);
                        }
                        else if(operation=="transfer"){
                            //transfer balances
                            balances[receiver] = ABDKMathQuad.add(balances[receiver], amount);
                            //transfer deposits
                            deposits[receiver][currency] = ABDKMathQuad.add(deposits[receiver][currency], value);
                        }
                    }
                    //amount to redeem is more than what is in deposit, so we need to remove deposit after redemption,
                    //and call the redeem function again for the balance amount that is not yet redeemed
                    else{
                        bytes16 proportionRedeemed = ABDKMathQuad.div(deposits[party][currency], value);
                        bytes16 balanceToRedeem = ABDKMathQuad.mul(amount, ABDKMathQuad.sub(ABDKMathQuad.fromUInt(1), proportionRedeemed));
                        // get amount to send
                        bytes16 amtSend = deposits[party][currency];
                        //deposit of the currency with the user (party) becomes zero
                        deposits[party][currency] = 0;
                        //reduces balances
                        balances[party] = ABDKMathQuad.sub(balances[party], ABDKMathQuad.mul(amount, proportionRedeemed));
                        if(operation=="redeem"){
                            //adjust total supply
                            totalSupply_ = ABDKMathQuad.sub(totalSupply_, ABDKMathQuad.mul(amount, proportionRedeemed));
                            // send redeemed currency to party which is all of the currency in deposit with this user (party)
                            address(uint160(party)).transfer(ABDKMathQuad.toUInt(amtSend));
                            //generate event
                            emit ViaCashRedeemed(currency, deposits[party][currency]);
                        }
                        else if(operation=="transfer"){
                            //transfer balances
                            balances[receiver] = ABDKMathQuad.add(balances[receiver], ABDKMathQuad.mul(amount, proportionRedeemed));
                            //transfer deposits
                            deposits[receiver][currency] = ABDKMathQuad.add(deposits[receiver][currency], amtSend);
                        }
                        redeem(balanceToRedeem, party, cashtokenName, operation, receiver);
                    }
                }
            }
        }
    }
    
    //get Via exchange rates from oracle and convert given currency and amount to via cash token
    function convertToVia(bytes16 amount, bytes32 paid_in_currency, bytes16 ethusd, bytes16 viarate) private view returns(bytes16){
        if(paid_in_currency=="ether"){
            //to first convert amount of ether passed to this function to USD
            bytes16 amountInUSD = ABDKMathQuad.div(ABDKMathQuad.mul(amount, ethusd), ABDKMathQuad.fromUInt(1000000000000000000));
            //to then convert USD to Via-currency if currency of this contract is not USD itself
            if(cashtokenName!="Via_USD"){
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

    //convert Via-currency (eg, Via-EUR, Via-INR, Via-USD) to Ether or another Via currency
    //viarate is 1 if pay out currency is ether and this via cash token to redeem is Via-USD, otherwise viarate is exchange rate between this cash token to Via-USD
    //if pay out currency is not ether, then viarate is exchange rate between this cash token and cash token to pay out 
    function convertFromVia(bytes16 amount, bytes32 payout_currency, bytes16 ethusd, bytes16 viarate) private pure returns(bytes16){
        //if currency to convert to is ether
        if(payout_currency=="ether"){
            bytes16 amountInViaUSD = ABDKMathQuad.mul(amount, viarate);
            bytes16 inEth = ABDKMathQuad.div(amountInViaUSD, ethusd);
            return inEth;
        }
        //else convert to another via currency
        else{
            return ABDKMathQuad.mul(viarate, amount);
        }
    }
    
}
