----------------------------
-- Copyright (C) 2026 CARTO
----------------------------

-- Converts z/x/y tile coordinates to a quadbin index using Morton/Z-order
-- interleaving of the x and y bits.
--
-- Oracle bit operation equivalents:
--   a << n  =>  a * POWER(2, n)
--   a >> n  =>  TRUNC(a / POWER(2, n))  (unsigned right shift)
--   a | b   =>  a + b - BITAND(a, b)
--   a & b   =>  BITAND(a, b)
--
-- Bit-mask constants (decimal equivalents of hex):
--   MASK_16  = 281470681808895     = 0x0000FFFF0000FFFF
--   MASK_8   = 71777214294589695   = 0x00FF00FF00FF00FF
--   MASK_4   = 1085102592571150095 = 0x0F0F0F0F0F0F0F0F
--   MASK_2   = 3689348814741910323 = 0x3333333333333333
--   MASK_1   = 6148914691236517205 = 0x5555555555555555
--   HEADER   = 4611686018427387904 = 0x4000000000000000
--   MODE_BIT = 576460752303423488  = 1 << 59
--   UNUSED   = 4503599627370495    = 0xFFFFFFFFFFFFF

CREATE OR REPLACE FUNCTION @@ORA_SCHEMA@@.QUADBIN_FROMZXY
(z NUMBER, x NUMBER, y NUMBER)
RETURN NUMBER
AS
    MASK_16 CONSTANT NUMBER := 281470681808895;
    MASK_8  CONSTANT NUMBER := 71777214294589695;
    MASK_4  CONSTANT NUMBER := 1085102592571150095;
    MASK_2  CONSTANT NUMBER := 3689348814741910323;
    MASK_1  CONSTANT NUMBER := 6148914691236517205;
    HEADER  CONSTANT NUMBER := 4611686018427387904;
    MODE_BIT CONSTANT NUMBER := 576460752303423488;
    UNUSED_MASK CONSTANT NUMBER := 4503599627370495;

    v_xx NUMBER;
    v_yy NUMBER;
    v_interleaved NUMBER;
    v_unused NUMBER;
    v_result NUMBER;
BEGIN
    IF z IS NULL OR x IS NULL OR y IS NULL THEN
        RETURN NULL;
    END IF;

    v_xx := x * POWER(2, 32 - z);
    v_yy := y * POWER(2, 32 - z);

    -- 5 rounds of bit-spreading (Morton interleaving preparation)
    -- Each round: val = (val | (val << shift)) & mask
    -- In Oracle: val = BITAND(val + val * POWER(2, shift) - BITAND(val, val * POWER(2, shift)), mask)

    -- Round 1: spread by 16
    v_xx := BITAND(v_xx + v_xx * POWER(2, 16) - BITAND(v_xx, v_xx * POWER(2, 16)), MASK_16);
    v_yy := BITAND(v_yy + v_yy * POWER(2, 16) - BITAND(v_yy, v_yy * POWER(2, 16)), MASK_16);

    -- Round 2: spread by 8
    v_xx := BITAND(v_xx + v_xx * POWER(2, 8) - BITAND(v_xx, v_xx * POWER(2, 8)), MASK_8);
    v_yy := BITAND(v_yy + v_yy * POWER(2, 8) - BITAND(v_yy, v_yy * POWER(2, 8)), MASK_8);

    -- Round 3: spread by 4
    v_xx := BITAND(v_xx + v_xx * POWER(2, 4) - BITAND(v_xx, v_xx * POWER(2, 4)), MASK_4);
    v_yy := BITAND(v_yy + v_yy * POWER(2, 4) - BITAND(v_yy, v_yy * POWER(2, 4)), MASK_4);

    -- Round 4: spread by 2
    v_xx := BITAND(v_xx + v_xx * POWER(2, 2) - BITAND(v_xx, v_xx * POWER(2, 2)), MASK_2);
    v_yy := BITAND(v_yy + v_yy * POWER(2, 2) - BITAND(v_yy, v_yy * POWER(2, 2)), MASK_2);

    -- Round 5: spread by 1
    v_xx := BITAND(v_xx + v_xx * 2 - BITAND(v_xx, v_xx * 2), MASK_1);
    v_yy := BITAND(v_yy + v_yy * 2 - BITAND(v_yy, v_yy * 2), MASK_1);

    -- Interleave: (x | (y << 1)) >> 12
    v_interleaved := TRUNC(
        (v_xx + v_yy * 2 - BITAND(v_xx, v_yy * 2)) / POWER(2, 12)
    );

    -- Unused bits (trailing 1s): UNUSED_MASK >> (z * 2)
    v_unused := TRUNC(UNUSED_MASK / POWER(2, z * 2));

    -- Combine all parts using OR via accumulator
    -- The parts occupy non-overlapping bit regions except interleaved|unused
    -- which share the lower 52 bits, so we must use proper OR
    v_result := HEADER;
    -- v_result |= MODE_BIT
    v_result := v_result + MODE_BIT - BITAND(v_result, MODE_BIT);
    -- v_result |= (z << 52)
    v_result := v_result + z * POWER(2, 52) - BITAND(v_result, z * POWER(2, 52));
    -- v_result |= v_interleaved
    v_result := v_result + v_interleaved - BITAND(v_result, v_interleaved);
    -- v_result |= v_unused
    v_result := v_result + v_unused - BITAND(v_result, v_unused);

    RETURN v_result;
END;
/
