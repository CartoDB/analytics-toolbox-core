----------------------------
-- Copyright (C) 2026 CARTO
----------------------------

-- Extracts z/x/y tile coordinates from a quadbin index by de-interleaving
-- the Morton-coded bits.
--
-- Bit-mask constants (decimal equivalents):
--   MASK_1   = 6148914691236517205 = 0x5555555555555555
--   MASK_2   = 3689348814741910323 = 0x3333333333333333
--   MASK_4   = 1085102592571150095 = 0x0F0F0F0F0F0F0F0F
--   MASK_8   = 71777214294589695   = 0x00FF00FF00FF00FF
--   MASK_16  = 281470681808895     = 0x0000FFFF0000FFFF
--   MASK_32  = 4294967295          = 0x00000000FFFFFFFF
--   MORTON_MASK = 4503599627370495 = 0xFFFFFFFFFFFFF (52-bit mask)

CREATE OR REPLACE FUNCTION @@ORA_SCHEMA@@.QUADBIN_TOZXY
(quadbin NUMBER)
RETURN VARCHAR2
AS
    MASK_1  CONSTANT NUMBER := 6148914691236517205;
    MASK_2  CONSTANT NUMBER := 3689348814741910323;
    MASK_4  CONSTANT NUMBER := 1085102592571150095;
    MASK_8  CONSTANT NUMBER := 71777214294589695;
    MASK_16 CONSTANT NUMBER := 281470681808895;
    MASK_32 CONSTANT NUMBER := 4294967295;
    MORTON_MASK CONSTANT NUMBER := 4503599627370495;

    v_z NUMBER;
    v_q NUMBER;
    v_x NUMBER;
    v_y NUMBER;
BEGIN
    IF quadbin IS NULL THEN
        RETURN NULL;
    END IF;

    -- Extract zoom: bits 52-56
    v_z := BITAND(TRUNC(quadbin / POWER(2, 52)), 31);

    -- Extract 52-bit Morton field, then shift left by 12
    v_q := BITAND(quadbin, MORTON_MASK) * POWER(2, 12);

    -- Separate even bits (x) and odd bits (y)
    v_x := v_q;
    v_y := TRUNC(v_q / 2);

    -- 5 rounds of bit-compacting (reverse of spreading)

    -- Step 1: mask with MASK_1
    v_x := BITAND(v_x, MASK_1);
    v_y := BITAND(v_y, MASK_1);

    -- Step 2: compact by 1 => (val | (val >> 1)) & MASK_2
    v_x := BITAND(v_x + TRUNC(v_x / 2) - BITAND(v_x, TRUNC(v_x / 2)), MASK_2);
    v_y := BITAND(v_y + TRUNC(v_y / 2) - BITAND(v_y, TRUNC(v_y / 2)), MASK_2);

    -- Step 3: compact by 2 => (val | (val >> 2)) & MASK_4
    v_x := BITAND(v_x + TRUNC(v_x / POWER(2, 2)) - BITAND(v_x, TRUNC(v_x / POWER(2, 2))), MASK_4);
    v_y := BITAND(v_y + TRUNC(v_y / POWER(2, 2)) - BITAND(v_y, TRUNC(v_y / POWER(2, 2))), MASK_4);

    -- Step 4: compact by 4 => (val | (val >> 4)) & MASK_8
    v_x := BITAND(v_x + TRUNC(v_x / POWER(2, 4)) - BITAND(v_x, TRUNC(v_x / POWER(2, 4))), MASK_8);
    v_y := BITAND(v_y + TRUNC(v_y / POWER(2, 4)) - BITAND(v_y, TRUNC(v_y / POWER(2, 4))), MASK_8);

    -- Step 5: compact by 8 => (val | (val >> 8)) & MASK_16
    v_x := BITAND(v_x + TRUNC(v_x / POWER(2, 8)) - BITAND(v_x, TRUNC(v_x / POWER(2, 8))), MASK_16);
    v_y := BITAND(v_y + TRUNC(v_y / POWER(2, 8)) - BITAND(v_y, TRUNC(v_y / POWER(2, 8))), MASK_16);

    -- Step 6: compact by 16 => (val | (val >> 16)) & MASK_32
    v_x := BITAND(v_x + TRUNC(v_x / POWER(2, 16)) - BITAND(v_x, TRUNC(v_x / POWER(2, 16))), MASK_32);
    v_y := BITAND(v_y + TRUNC(v_y / POWER(2, 16)) - BITAND(v_y, TRUNC(v_y / POWER(2, 16))), MASK_32);

    -- Right-shift by (32 - z) to get final coordinates
    v_x := TRUNC(v_x / POWER(2, 32 - v_z));
    v_y := TRUNC(v_y / POWER(2, 32 - v_z));

    RETURN '{"z":' || v_z || ',"x":' || v_x || ',"y":' || v_y || '}';
END;
/
