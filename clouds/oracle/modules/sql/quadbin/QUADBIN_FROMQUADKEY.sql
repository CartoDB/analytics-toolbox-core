----------------------------
-- Copyright (C) 2026 CARTO
----------------------------

-- Converts a quadkey string (base-4 digits like '0321') to a quadbin index.
-- The length of the quadkey determines the zoom level; each digit encodes
-- one level of the tile hierarchy as y_bit*2 + x_bit.
--
-- The quadkey string IS the base-4 representation of the interleaved xy
-- Morton code, so we parse it as a base-4 number and assemble the quadbin
-- directly from its component bit fields.
--
-- Bit-field constants (decimal equivalents):
--   HEADER   = 4611686018427387904 = 0x4000000000000000
--   MODE_BIT = 576460752303423488  = 1 << 59
--   UNUSED_MASK = 4503599627370495 = 0xFFFFFFFFFFFFF (52-bit mask)

CREATE OR REPLACE FUNCTION @@ORA_SCHEMA@@.QUADBIN_FROMQUADKEY
(quadkey VARCHAR2)
RETURN NUMBER
AS
    HEADER      CONSTANT NUMBER := 4611686018427387904;
    MODE_BIT    CONSTANT NUMBER := 576460752303423488;
    UNUSED_MASK CONSTANT NUMBER := 4503599627370495;

    v_z      NUMBER;
    v_xy     NUMBER;
    v_i      NUMBER;
    v_digit  NUMBER;
    v_unused NUMBER;
    v_result NUMBER;
BEGIN
    IF quadkey IS NULL THEN
        RETURN NULL;
    END IF;

    -- In Oracle '' IS NULL, so LENGTH(NULL) is NULL.
    -- Empty-string quadkey (zoom 0) cannot be distinguished from NULL.
    -- Use QUADBIN_FROMZXY(0, 0, 0) for zoom level 0 instead.
    v_z := LENGTH(quadkey);

    -- Parse the quadkey string as a base-4 number
    v_xy := 0;
    FOR v_i IN 1 .. v_z LOOP
        v_digit := TO_NUMBER(SUBSTR(quadkey, v_i, 1));
        v_xy := v_xy * 4 + v_digit;
    END LOOP;

    -- Trailing unused bits (all 1s below the significant region)
    -- unused = UNUSED_MASK >> (z * 2)
    IF v_z * 2 < 52 THEN
        v_unused := TRUNC(UNUSED_MASK / POWER(2, v_z * 2));
    ELSE
        v_unused := 0;
    END IF;

    -- Assemble: HEADER | MODE_BIT | (z << 52) | (xy << (52 - z*2)) | unused
    -- All fields occupy non-overlapping bit ranges except xy|unused in the
    -- lower 52 bits, so we use OR (a + b - BITAND(a,b)) for safety.
    v_result := HEADER;
    -- v_result |= MODE_BIT
    v_result := v_result + MODE_BIT - BITAND(v_result, MODE_BIT);
    -- v_result |= (z << 52)
    v_result := v_result + v_z * POWER(2, 52)
              - BITAND(v_result, v_z * POWER(2, 52));
    -- v_result |= (xy << (52 - z*2))
    IF v_z > 0 THEN
        v_result := v_result + v_xy * POWER(2, 52 - v_z * 2)
                  - BITAND(v_result, v_xy * POWER(2, 52 - v_z * 2));
    END IF;
    -- v_result |= unused
    v_result := v_result + v_unused - BITAND(v_result, v_unused);

    RETURN v_result;
END;
/
