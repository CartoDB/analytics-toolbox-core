# Copyright (c) 2020-2021 SafeGraph Inc.
# Copyright (c) 2021, CARTO

import re

# Placekey constants
BASE_RESOLUTION = 12
BASE_CELL_SHIFT = 2 ** (3 * 15)  # Adding this will increment the base cell value by 1
ALPHABET = "23456789BCDFGHJKMNPQRSTVWXYZ".lower()
ALPHABET_LENGTH = len(ALPHABET)
CODE_LENGTH = 9
TUPLE_LENGTH = 3
UNUSED_RESOLUTION_FILLER = 2 ** (3 * (15 - BASE_RESOLUTION)) - 1
PADDING_CHAR = "a"
HEADER_INT = int("8a0000000000000", 16)
REPLACEMENT_CHARS = "eu"
REPLACEMENT_MAP = (
    ("prn", "pre"),
    ("f4nny", "f4nne"),
    ("tw4t", "tw4e"),
    ("ngr", "ngu"),  # 'u' avoids introducing 'gey'
    ("dck", "dce"),
    ("vjn", "vju"),  # 'u' avoids introducing 'jew'
    ("fck", "fce"),
    ("pns", "pne"),
    ("sht", "she"),
    ("kkk", "kke"),
    ("fgt", "fgu"),  # 'u' avoids introducing 'gey'
    ("dyk", "dye"),
    ("bch", "bce"),
)

FIRST_TUPLE_REGEX = "[" + ALPHABET + REPLACEMENT_CHARS + PADDING_CHAR + "]{3}"
TUPLE_REGEX = "[" + ALPHABET + REPLACEMENT_CHARS + "]{3}"
WHERE_REGEX = re.compile(
    "^" + "-".join([FIRST_TUPLE_REGEX, TUPLE_REGEX, TUPLE_REGEX]) + "$"
)
WHAT_REGEX = re.compile("^[" + ALPHABET + "]{3,}(-[" + ALPHABET + "]{3,})?$")

# H3 constants
H3_CELL_MODE = 1
H3_PER_DIGIT_OFFSET = 3
H3_DIGIT_MASK = 7
H3_NUM_DIGITS = 7
H3_MAX_RES = 15
H3_NUM_BITS = 64
H3_MAX_OFFSET = 63
H3_MODE_OFFSET = 59
H3_RESERVED_OFFSET = 56
H3_BC_OFFSET = 45
H3_RES_OFFSET = 52
H3_NUM_BASE_CELLS = 122
H3_HIGH_BIT_MASK = 1 << H3_MAX_OFFSET
H3_MODE_MASK = 15 << H3_MODE_OFFSET
H3_RESERVED_MASK = 7 << H3_RESERVED_OFFSET
H3_BC_MASK = 127 << H3_BC_OFFSET
H3_RES_MASK = 15 << H3_RES_OFFSET
H3_CENTER_DIGIT = 0
H3_K_AXES_DIGIT = 1
H3_BASE_CELL_PENTA = [
    0,
    0,
    0,
    0,
    1,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    1,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    1,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    1,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    1,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    1,
    0,
    0,
    0,
    0,
    1,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    1,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    1,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    1,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    1,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    1,
    0,
    0,
    0,
    0,
]


# Placekey main functions


def placekey_is_valid(placekey):
    """
    Boolean for whether or not the format of a Placekey is valid.

    It includes checks for valid encoding of location.

    :param placekey: Placekey (string)
    :return: True if the Placekey is valid, False otherwise
    """
    if placekey is None:
        return False

    what, where = parse_plakey(placekey)

    if what:
        return bool(WHERE_REGEX.match(where)) and bool(WHAT_REGEX.match(what))
    else:
        return bool(WHERE_REGEX.match(where))


def h3_to_placekey(h3_index):
    """
    Convert an H3 hexadecimal string into a Placekey string.

    :param h3_index : H3 (string)
    :return: Placekey (string)
    """
    return encode_h3_int(string_to_h3(h3_index))


def placekey_to_h3(placekey):
    """
    Convert a Placekey string into an H3 hexadecimal string.

    :param placekey : Placekey index (string)
    :return: H3 (string)
    """
    return int_to_h3_string(placekey_to_h3_integer(placekey))


# Auxiliary functions


def string_to_h3(h3_index):
    result = 0
    if not isinstance(h3_index, str):
        return result

    try:
        result = int(h3_index, 16)
    except ValueError:
        result = 0

    return result


def encode_h3_int(h3_integer):
    short_h3_integer = shorten_h3_integer(h3_integer)
    encoded_short_h3 = encode_short_int(short_h3_integer)

    clean_encoded_short_h3 = clean_string(encoded_short_h3)
    if len(clean_encoded_short_h3) <= CODE_LENGTH:
        clean_encoded_short_h3 = str.rjust(
            clean_encoded_short_h3, CODE_LENGTH, PADDING_CHAR
        )

    return "@" + "-".join(
        clean_encoded_short_h3[i: i + TUPLE_LENGTH]
        for i in range(0, len(clean_encoded_short_h3), TUPLE_LENGTH)
    )


def shorten_h3_integer(h3_integer):
    # Cuts off the 12 left-most bits that don't code location
    out = (h3_integer + BASE_CELL_SHIFT) % (2**52)
    # Cuts off the rightmost bits corresponding to resolutions
    # greater than the base resolution
    out = out >> (3 * (15 - BASE_RESOLUTION))
    return out


def encode_short_int(x):
    if x == 0:
        return ALPHABET[0]
    else:
        res = ""
        while x > 0:
            remainder = x % ALPHABET_LENGTH
            res = ALPHABET[remainder] + res
            x = x // ALPHABET_LENGTH
        return res


def clean_string(s):
    # Replacement should be in order
    for k, v in REPLACEMENT_MAP:
        if k in s:
            s = s.replace(k, v)
    return s


def parse_plakey(placekey):
    if "@" in placekey:
        what, where = placekey.split("@")
    else:
        what, where = None, placekey

    return what, where


def placekey_to_h3_integer(placekey):
    _, where_part = parse_plakey(placekey)
    code = strip_encoding(where_part)
    dirty_encoding = dirty_string(code)
    short_h3_integer = decode_string(dirty_encoding)
    return unshorten_h3_integer(short_h3_integer)


def strip_encoding(s):
    s = s.replace("@", "").replace("-", "").replace(PADDING_CHAR, "")
    return s


def dirty_string(s):
    # Replacement should be in (reversed) order
    for k, v in REPLACEMENT_MAP[::-1]:
        if v in s:
            s = s.replace(v, k)
    return s


def decode_string(s):
    val = 0
    for i in range(len(s)):
        val += (ALPHABET_LENGTH**i) * ALPHABET.index(s[-1 - i])
    return val


def unshorten_h3_integer(short_h3_integer):
    unshifted_int = short_h3_integer << (3 * (15 - BASE_RESOLUTION))
    rebuilt_int = (
        (HEADER_INT + UNUSED_RESOLUTION_FILLER) - BASE_CELL_SHIFT
    ) + unshifted_int

    return rebuilt_int


def int_to_h3_string(h3_integer):
    return str(hex(h3_integer)).lstrip("0x")


# H3 auxiliary functions (These functions should be located in the H3 module)


def h3_is_valid(h3_index):
    h3_integer = string_to_h3(h3_index)

    if h3_integer == 0:
        return False

    if (int)((h3_integer & H3_HIGH_BIT_MASK) >> H3_MAX_OFFSET) != 0:
        return False

    if (int)((h3_integer & H3_MODE_MASK) >> H3_MODE_OFFSET) != H3_CELL_MODE:
        return False

    if (int)((h3_integer & H3_RESERVED_MASK) >> H3_RESERVED_OFFSET) != 0:
        return False

    base_cell = (h3_integer & H3_BC_MASK) >> H3_BC_OFFSET
    if base_cell < 0 or base_cell >= H3_NUM_BASE_CELLS:
        return False

    res = (int)((h3_integer & H3_RES_MASK) >> H3_RES_OFFSET)

    if res < 0 or res > H3_MAX_RES:
        # Resolutions less than zero can not be represented in an index
        return False

    found_first_non_zero_digit = False

    for i in range(1, res + 1):
        digit = (
            h3_integer >> ((H3_MAX_RES - (res)) * H3_PER_DIGIT_OFFSET)
        ) & H3_DIGIT_MASK

        if not found_first_non_zero_digit and digit != H3_CENTER_DIGIT:
            found_first_non_zero_digit = True
            if H3_BASE_CELL_PENTA[base_cell] == 1 and digit == H3_K_AXES_DIGIT:
                return False

        if digit < H3_CENTER_DIGIT or digit >= H3_NUM_DIGITS:
            return False

    for r in range(res + 1, H3_MAX_RES + 1):
        digit = (
            h3_integer >> ((H3_MAX_RES - (r)) * H3_PER_DIGIT_OFFSET)
        ) & H3_DIGIT_MASK
        if digit != H3_NUM_DIGITS:
            return False

    return True
