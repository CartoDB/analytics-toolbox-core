const LO_PART = 0;
const HI_PART = 1;
const INT_SIZE = 32;
const BASE_16 = 16;
const BASE_RESOLUTION = 12;
const HEADER_INT = [0x00000000, 0x8a00000];
const BASE_CELL_SHIFT = [0, 0x2000];
const UNUSED_RESOLUTION_FILLER = [0x1ff, 0];

function assert(condition, message = 'assertion failed') {
  if (!condition) {
    throw new Error(message);
  }
}

function leftShiftH3Integer(h3Integer, bits, result = [0, 0]) {
  assert(bits <= INT_SIZE);
  result[LO_PART] = h3Integer[LO_PART];
  result[HI_PART] = h3Integer[HI_PART];
  result[HI_PART] <<= bits;
  const temp = result[LO_PART] >>> INT_SIZE - bits;
  result[HI_PART] |= temp;
  result[LO_PART] <<= bits;
  return result;
}
function rightShiftH3Integer(h3Integer, bits, result = [0, 0]) {
  assert(bits <= INT_SIZE);
  result[LO_PART] = h3Integer[LO_PART];
  result[HI_PART] = h3Integer[HI_PART];
  result[LO_PART] >>>= bits;
  const temp = result[HI_PART] << INT_SIZE - bits;
  result[LO_PART] |= temp;
  result[HI_PART] >>>= bits;
  return result;
}
function orH3Integers(left, right, result = [0, 0]) {
  result[LO_PART] = left[LO_PART] | right[LO_PART];
  result[HI_PART] = left[HI_PART] | right[HI_PART];
  return result;
}
function maskLeftBits(h3Integer, bits, result = [0, 0]) {
  assert(bits <= INT_SIZE);
  const mask = bits === 32 ? 0 : 0xffffffff >>> bits;
  result[LO_PART] = h3Integer[LO_PART];
  result[HI_PART] = h3Integer[HI_PART] & mask;
  return result;
}
function addH3Integers(left, right, result = [0, 0]) {
  let carry = Boolean(left[LO_PART] & right[LO_PART] & 0x80000000);
  const anyHighBit = (left[LO_PART] | right[LO_PART]) & 0x80000000;

  if (carry || anyHighBit) {
    result[LO_PART] = left[LO_PART] & 0x7fffffff;
    result[LO_PART] += right[LO_PART] & 0x7fffffff;

    if (!carry) {
      if (result[LO_PART] & 0x80000000) {
        carry = true;
        result[LO_PART] &= 0x7fffffff;
      } else {
        result[LO_PART] |= 0x80000000;
      }
    }
  } else {
    result[LO_PART] = left[LO_PART] + right[LO_PART];
  }

  result[HI_PART] = left[HI_PART] + right[HI_PART];

  if (carry) {
    result[HI_PART] += 1;
  }

  return result;
}
function subtractH3Integers(left, right, result = [0, 0]) {
  assert(left[HI_PART] >= right[HI_PART]);

  if (left[HI_PART] === right[HI_PART]) {
    assert(left[LO_PART] >= right[LO_PART]);
  }

  result[LO_PART] = left[LO_PART] - right[LO_PART];
  const borrow = left[LO_PART] < right[LO_PART] ? 1 : 0;
  result[HI_PART] = left[HI_PART] - right[HI_PART] - borrow;
  return result;
}
function scaleH3Integer(scalar, value, result = [0, 0]) {
  for (let i = 0; i < scalar; i++) {
    result = addH3Integers(value, result);
  }

  return result;
}
function h3IntegerToJSInteger(h3Integer) {
  if (h3Integer[HI_PART] > 0xfffff || h3Integer[HI_PART] < 0) {
    throw new Error('Cannot encode integers beyond 52 bits');
  }

  const shiftedHiPart = h3Integer[HI_PART] * Math.pow(2, 32);
  const maskedLoPart = h3Integer[LO_PART] & 0x7fffffff;
  const msbLoPart = h3Integer[LO_PART] & 0x80000000 ? 0x80000000 : 0;
  return maskedLoPart + msbLoPart + shiftedHiPart;
}
function leftPad(string, length = 8, char = ' ') {
  const padLength = Math.max(length - string.length, 0);
  return "".concat(char.repeat(padLength)).concat(string);
}
function hexFrom32Bit(num) {
  if (num >= 0) {
    return num.toString(BASE_16);
  }

  num = num & 0x7fffffff;
  let tempStr = leftPad(num.toString(BASE_16), 8, '0');
  const topNum = (parseInt(tempStr[0], BASE_16) + 8).toString(BASE_16);
  tempStr = topNum + tempStr.substring(1);
  return tempStr;
}
function h3IntegerToString(h3Integer) {
  const upperStr = hexFrom32Bit(h3Integer[HI_PART]);
  const shouldPad = upperStr !== '0' ? 8 : 0;
  return (upperStr !== '0' ? upperStr : '') + leftPad(hexFrom32Bit(h3Integer[LO_PART]), shouldPad, '0');
}
const INVALID_HEXIDECIMAL_CHAR = /[^0-9a-fA-F]/;
function stringToH3Integer(h3Index, result = [0, 0]) {
  if (typeof h3Index !== 'string' || INVALID_HEXIDECIMAL_CHAR.test(h3Index)) {
    return result;
  }

  const higher = parseInt(h3Index.substring(0, h3Index.length - 8), BASE_16);
  const lower = parseInt(h3Index.substring(h3Index.length - 8), BASE_16);
  result[LO_PART] = lower;
  result[HI_PART] = Number.isFinite(higher) ? higher : 0;
  return result;
}
function shortenH3Integer(h3Integer) {
  const shiftedH3Integer = addH3Integers(h3Integer, BASE_CELL_SHIFT);
  const masked = maskLeftBits(shiftedH3Integer, 12);
  const result = rightShiftH3Integer(masked, 3 * (15 - BASE_RESOLUTION), masked);
  return result;
}
function unshortenH3Integer(shortH3Integer, result = [0, 0]) {
  const unshiftedInt = leftShiftH3Integer(shortH3Integer, 3 * (15 - BASE_RESOLUTION));
  const rebuiltInt = addH3Integers(subtractH3Integers(addH3Integers(HEADER_INT, UNUSED_RESOLUTION_FILLER), BASE_CELL_SHIFT), unshiftedInt);
  return rebuiltInt;
}
//# sourceMappingURL=h3-integer.js.map
