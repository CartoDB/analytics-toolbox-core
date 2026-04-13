----------------------------
-- Copyright (C) 2026 CARTO
----------------------------

-- Converts a quadbin index to a quadkey string (base-4 digits).
-- Extracts the zoom level and the interleaved xy Morton code, then
-- converts the Morton code to a base-4 string zero-padded to z digits.
--
-- Bit-field constants (decimal equivalents):
--   MORTON_MASK = 4503599627370495 = 0xFFFFFFFFFFFFF (52-bit mask)

CREATE OR REPLACE FUNCTION @@ORA_SCHEMA@@.QUADBIN_TOQUADKEY
(quadbin NUMBER)
RETURN VARCHAR2
AS
    MORTON_MASK CONSTANT NUMBER := 4503599627370495;

    v_z       NUMBER;
    v_xy      NUMBER;
    v_result  VARCHAR2(26);
    v_digit   NUMBER;
BEGIN
    IF quadbin IS NULL THEN
        RETURN NULL;
    END IF;

    -- Extract zoom: bits 52-56
    v_z := BITAND(TRUNC(quadbin / POWER(2, 52)), 31);

    IF v_z = 0 THEN
        RETURN '';
    END IF;

    -- Extract the interleaved xy field: lower 52 bits >> (52 - z*2)
    v_xy := TRUNC(BITAND(quadbin, MORTON_MASK) / POWER(2, 52 - v_z * 2));

    -- Convert to base-4 string by repeatedly extracting the least-significant
    -- base-4 digit and prepending it. This produces exactly z digits.
    v_result := '';
    FOR i IN 1 .. v_z LOOP
        v_digit := MOD(v_xy, 4);
        v_result := TO_CHAR(v_digit) || v_result;
        v_xy := TRUNC(v_xy / 4);
    END LOOP;

    RETURN v_result;
END;
/
