----------------------------
-- Copyright (C) 2026 CARTO
----------------------------

CREATE OR REPLACE FUNCTION @@ORA_SCHEMA@@.H3_TOCHILDREN
(
    h3_index VARCHAR2, resolution NUMBER
)
RETURN VARCHAR2
DETERMINISTIC
IS
    -- H3 bit layout constants
    RAW_BYTE_LENGTH CONSTANT PLS_INTEGER := 16;
    MIN_RESOLUTION CONSTANT PLS_INTEGER := 0;
    MAX_RESOLUTION CONSTANT PLS_INTEGER := 15;
    DIGIT_BITS CONSTANT PLS_INTEGER := 3;
    DIGITS_PER_INDEX CONSTANT PLS_INTEGER := 15;
    H3_CELL_MODE CONSTANT PLS_INTEGER := 1;
    UNUSED_DIGIT CONSTANT PLS_INTEGER := 7;
    NUM_HEX_CHILDREN CONSTANT PLS_INTEGER := 7;  -- digits 0-6
    FIRST_DIGIT_BIT CONSTANT PLS_INTEGER := 45;   -- bit position of digit 1 start (bit 44 is LSB of digit 15)
    RESOLUTION_BIT_OFFSET CONSTANT PLS_INTEGER := 52;  -- bit position where resolution starts
    RESOLUTION_MASK CONSTANT NUMBER := 15;  -- 4 bits for resolution (0xF)
    DIGIT_MASK CONSTANT PLS_INTEGER := 7;   -- 3 bits for each digit (0x7)
    HEX_FORMAT_MASK CONSTANT VARCHAR2(18) := 'FMXXXXXXXXXXXXXXXX';
    HEX_PARSE_MASK CONSTANT VARCHAR2(16) := 'XXXXXXXXXXXXXXXX';

    -- Working variables
    h3_raw RAW(8);
    is_valid BOOLEAN;
    current_res PLS_INTEGER;
    target_res PLS_INTEGER;
    h3_int NUMBER;
    base_int NUMBER;
    digit_bit_pos PLS_INTEGER;
    shift_amount NUMBER;
    clear_mask NUMBER;
    child_int NUMBER;
    child_hex VARCHAR2(16);
    is_pent BOOLEAN;
    json_result VARCHAR2(32767);
    first_entry BOOLEAN;

    -- Collection types for iterative expansion
    TYPE num_array IS TABLE OF NUMBER INDEX BY PLS_INTEGER;
    current_cells num_array;
    next_cells num_array;
    cell_count PLS_INTEGER;
    next_count PLS_INTEGER;
    i PLS_INTEGER;
    d PLS_INTEGER;

    -- Helper: right-shift a NUMBER by n bits
    FUNCTION rshift(val NUMBER, n PLS_INTEGER) RETURN NUMBER IS
    BEGIN
        RETURN TRUNC(val / POWER(2, n));
    END rshift;

    -- Helper: left-shift a NUMBER by n bits
    FUNCTION lshift(val NUMBER, n PLS_INTEGER) RETURN NUMBER IS
    BEGIN
        RETURN val * POWER(2, n);
    END lshift;

    -- Helper: bitwise OR (Oracle only has BITAND)
    FUNCTION bitor(a NUMBER, b NUMBER) RETURN NUMBER IS
    BEGIN
        RETURN a + b - BITAND(a, b);
    END bitor;

    -- Helper: set the resolution field (bits 55-52) to a given value
    FUNCTION set_resolution(val NUMBER, res PLS_INTEGER) RETURN NUMBER IS
        res_clear_mask NUMBER;
    BEGIN
        -- Clear bits 55-52: mask = NOT (0xF << 52)
        res_clear_mask := lshift(RESOLUTION_MASK, RESOLUTION_BIT_OFFSET);
        RETURN bitor(BITAND(val, POWER(2, 64) - 1 - res_clear_mask),
                     lshift(res, RESOLUTION_BIT_OFFSET));
    END set_resolution;

    -- Helper: set digit at given resolution level (1-based) to a value
    FUNCTION set_digit(val NUMBER, res_level PLS_INTEGER, digit PLS_INTEGER) RETURN NUMBER IS
        bit_pos PLS_INTEGER;
        field_mask NUMBER;
    BEGIN
        -- Digit for resolution R occupies bits (44 - 3*(R-1)) down to (42 - 3*(R-1))
        bit_pos := FIRST_DIGIT_BIT - DIGIT_BITS * res_level;
        field_mask := lshift(DIGIT_MASK, bit_pos);
        RETURN bitor(BITAND(val, POWER(2, 64) - 1 - field_mask),
                     lshift(digit, bit_pos));
    END set_digit;

    -- Helper: get digit at given resolution level (1-based)
    FUNCTION get_digit(val NUMBER, res_level PLS_INTEGER) RETURN PLS_INTEGER IS
        bit_pos PLS_INTEGER;
    BEGIN
        bit_pos := FIRST_DIGIT_BIT - DIGIT_BITS * res_level;
        RETURN BITAND(rshift(val, bit_pos), DIGIT_MASK);
    END get_digit;

    -- Helper: check if a cell is a pentagon using SDO_UTIL
    FUNCTION check_is_pentagon(cell_val NUMBER) RETURN BOOLEAN IS
        hex_str VARCHAR2(16);
        cell_raw RAW(8);
    BEGIN
        hex_str := TO_CHAR(cell_val, HEX_FORMAT_MASK);
        cell_raw := HEXTORAW(LPAD(hex_str, RAW_BYTE_LENGTH, '0'));
        RETURN SDO_UTIL.H3_IS_PENTAGON(cell_raw);
    EXCEPTION
        WHEN OTHERS THEN
            RETURN FALSE;
    END check_is_pentagon;

    -- Helper: prepare a cell for child generation at the next resolution
    -- Sets resolution to next_res and clears all digit slots from next_res to 15
    FUNCTION prepare_for_children(val NUMBER, next_res PLS_INTEGER) RETURN NUMBER IS
        result NUMBER;
        r PLS_INTEGER;
    BEGIN
        result := set_resolution(val, next_res);
        -- Set digit at next_res to 0 (will be overwritten per child)
        -- Set all digits from next_res+1 to DIGITS_PER_INDEX to UNUSED_DIGIT (7)
        result := set_digit(result, next_res, 0);
        FOR r IN (next_res + 1) .. DIGITS_PER_INDEX LOOP
            result := set_digit(result, r, UNUSED_DIGIT);
        END LOOP;
        RETURN result;
    END prepare_for_children;

BEGIN
    -- Null / invalid guard
    IF h3_index IS NULL OR resolution IS NULL THEN
        RETURN '[]';
    END IF;

    target_res := TRUNC(resolution);
    IF target_res < MIN_RESOLUTION OR target_res > MAX_RESOLUTION THEN
        RETURN '[]';
    END IF;

    -- Validate input H3 index
    BEGIN
        h3_raw := HEXTORAW(LPAD(h3_index, RAW_BYTE_LENGTH, '0'));
        is_valid := SDO_UTIL.H3_IS_VALID_CELL(h3_raw);
        IF NOT is_valid THEN
            RETURN '[]';
        END IF;
    EXCEPTION
        WHEN OTHERS THEN
            RETURN '[]';
    END;

    current_res := SDO_UTIL.H3_RESOLUTION(h3_raw);

    -- Target coarser than current -> empty
    IF target_res < current_res THEN
        RETURN '[]';
    END IF;

    -- Parse H3 hex string to integer
    h3_int := TO_NUMBER(h3_index, HEX_PARSE_MASK);

    -- Same resolution -> return self
    IF target_res = current_res THEN
        RETURN '["' || h3_index || '"]';
    END IF;

    -- Iterative expansion: level by level from current_res to target_res
    current_cells(1) := h3_int;
    cell_count := 1;

    FOR lvl IN (current_res + 1) .. target_res LOOP
        next_count := 0;
        FOR i IN 1 .. cell_count LOOP
            -- Prepare the base cell for this level
            base_int := prepare_for_children(current_cells(i), lvl);
            is_pent := check_is_pentagon(current_cells(i));

            -- Generate children: digits 0-6 (skip 1 for pentagons)
            FOR d IN 0 .. (NUM_HEX_CHILDREN - 1) LOOP
                IF NOT is_pent OR d <> 1 THEN
                    next_count := next_count + 1;
                    next_cells(next_count) := set_digit(base_int, lvl, d);
                END IF;
            END LOOP;
        END LOOP;

        -- Swap: next becomes current for the next level
        current_cells.DELETE;
        cell_count := next_count;
        FOR i IN 1 .. cell_count LOOP
            current_cells(i) := next_cells(i);
        END LOOP;
        next_cells.DELETE;
    END LOOP;

    -- Build JSON array result
    json_result := '[';
    first_entry := TRUE;
    FOR i IN 1 .. cell_count LOOP
        child_hex := LOWER(LTRIM(TO_CHAR(current_cells(i), HEX_FORMAT_MASK), '0'));
        IF child_hex IS NULL OR LENGTH(child_hex) = 0 THEN
            child_hex := '0';
        END IF;
        IF first_entry THEN
            first_entry := FALSE;
        ELSE
            json_result := json_result || ',';
        END IF;
        json_result := json_result || '"' || child_hex || '"';
    END LOOP;
    json_result := json_result || ']';

    RETURN json_result;
EXCEPTION
    WHEN OTHERS THEN
        RETURN '[]';
END H3_TOCHILDREN;
/
