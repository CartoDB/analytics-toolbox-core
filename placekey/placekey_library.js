// -----------------------------------------------------------------------
// --
// -- Copyright (C) 2021 CARTO
// --
// -----------------------------------------------------------------------

/* exported placekeyVersion */
function placekeyVersion() {
    return '1.0.1.1';
}
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
    return ''.concat(char.repeat(padLength)).concat(string);
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
// # sourceMappingURL=h3-integer.js.map
/* eslint-disable no-unused-vars */
const RESOLUTION = 10;
const ALPHABET = '23456789bcdfghjkmnpqrstvwxyz';
const ALPHABET_LENGTH = ALPHABET.length;
const CODE_LENGTH = 9;
const TUPLE_LENGTH = 3;
const PADDING_CHAR = 'a';
const PADDING_REGEX = /a/g;
const REPLACEMENT_CHARS = 'eu';

// Two copies of the REPLACEMENT_MAP are here to hold the regular expression objects
// needed. Both should be in the same order as REPLACEMENT_MAP.
const REPLACEMENT_MAP_BACKWARD = {
    prn: /pre/g,
    f4nny: /f4nne/g,
    tw4t: /gtw4e/g,
    ngr: /ngu/g, // 'u' avoids introducing 'gey'
    dck: /dce/g,
    vjn: /vju/g, // 'u' avoids introducing 'jew'
    fck: /fce/g,
    pns: /pne/g,
    sht: /she/g,
    kkk: /kke/g,
    fgt: /fgu/g, // 'u' avoids introducing 'gey'
    dyk: /dye/g,
    bch: /bce/g
};
const REPLACEMENT_MAP_FORWARD = {
    pre: /prn/g,
    f4nne: /f4nny/g,
    gtw4e: /tw4t/g,
    ngu: /ngr/g, // 'u' avoids introducing 'gey'
    dce: /dck/g,
    vju: /vjn/g, // 'u' avoids introducing 'jew'
    fce: /fck/g,
    pne: /pns/g,
    she: /sht/g,
    kke: /kkk/g,
    fgu: /fgt/g, // 'u' avoids introducing 'gey'
    dye: /dyk/g,
    bce: /bch/g
};

const FIRST_TUPLE_REGEX = '['.concat(ALPHABET).concat(REPLACEMENT_CHARS).concat(PADDING_CHAR, ']{3}');
const TUPLE_REGEX = '['.concat(ALPHABET).concat(REPLACEMENT_CHARS, ']{3}');
const WHERE_REGEX = new RegExp('^'.concat([FIRST_TUPLE_REGEX, TUPLE_REGEX, TUPLE_REGEX].join('-'), '$'));
const WHAT_REGEX = new RegExp('^['.concat(ALPHABET, ']{3}(-[').concat(ALPHABET, ']{3})?$'));
function placekeyIsValid(placekey) {
    if (typeof placekey !== 'string') {
        return false;
    }

    let what;
    let where;

    if (placekey.includes('@')) {
        [what, where] = placekey.split('@');
    } else {
        [what, where] = [null, placekey];
    }

    if (what) {
        return Boolean(where.match(WHERE_REGEX) && what.match(WHAT_REGEX));
    }

    return Boolean(where.match(WHERE_REGEX));
}
function placekeyToH3(placekey) {
    return h3IntegerToString(placekeyToH3Integer(placekey));
}
function h3ToPlacekey(h3index) {
    return h3IntegerToPlacekey(stringToH3Integer(h3index));
}
function h3IntegerToPlacekey(h3Integer) {
    const shortH3Integer = shortenH3Integer(h3Integer);
    const encodedShortH3 = encodeShortInt(shortH3Integer);
    let cleanEncodedShortH3 = cleanString(encodedShortH3);

    if (cleanEncodedShortH3.length <= CODE_LENGTH) {
        cleanEncodedShortH3 = cleanEncodedShortH3.padStart(CODE_LENGTH, PADDING_CHAR);
    }

    const cleanChars = cleanEncodedShortH3.split('');
    const tuples = [cleanChars.splice(0, TUPLE_LENGTH).join(''), cleanChars.splice(0, TUPLE_LENGTH).join(''), cleanChars.join('')];
    return '@' + tuples.join('-');
}

function placekeyToH3Integer(placekey) {
    const wherePart = getPlacekeyLocation(placekey);
    const code = stripEncoding(wherePart);
    const dirtyEncoding = dirtyString(code);
    const shortH3Integer = decodeString(dirtyEncoding);
    return unshortenH3Integer(shortH3Integer);
}

function getPlacekeyLocation(placekey) {
    return placekey.includes('@') ? placekey.split('@')[1] : placekey;
}

function stripEncoding(string) {
    return string.replace(/@/g, '').replace(/-/g, '').replace(PADDING_REGEX, '');
}

function cleanString(string) {
    for (const [replacement, regexp] of Object.entries(REPLACEMENT_MAP_FORWARD)) {
        string = string.replace(regexp, replacement);
    }
    return string;
}

function dirtyString(string) {
    for (const [replacement, regexp] of Object.entries(REPLACEMENT_MAP_BACKWARD).reverse()) {
        string = string.replace(regexp, replacement);
    }
    return string;
}

const DECODE_OFFSETS = [[0x1, 0], [0x1c, 0], [0x310, 0], [0x55c0, 0], [0x96100, 0],
    [0x1069c00, 0], [0x1cb91000, 0], [0x243dc000, 0x3], [0xf6c10000, 0x57], [0xfd1c0000, 0x99e]];

function decodeString(string) {
    const value = [0, 0];

    for (let i = 0; i < string.length; ++i) {
        const character = string[string.length - 1 - i];
        const indexOfCharacter = ALPHABET.indexOf(character);
        const offset = DECODE_OFFSETS[i];
        const valueOfCharacter = scaleH3Integer(indexOfCharacter, offset);
        addH3Integers(value, valueOfCharacter, value);
    }

    return value;
}

function encodeShortInt(x) {
    if (x === 0) {
        return ALPHABET[0];
    }

    let int = h3IntegerToJSInteger(x);
    let result = '';

    while (int > 0) {
        const remainder = int % ALPHABET_LENGTH;
        result = ALPHABET[remainder] + result;
        int = Math.floor(int / ALPHABET_LENGTH);
    }

    return result;
}
// # sourceMappingURL=placekey.js.map
/* eslint-enable no-unused-vars */
