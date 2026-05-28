----------------------------
-- Copyright (C) 2026 CARTO
----------------------------

-- Returns the parent quadbin at the specified (coarser) resolution.
-- Returns NULL if inputs are NULL, resolution is out of [0,26],
-- or target resolution is greater than the current resolution.
--
-- Oracle bit operation equivalents:
--   a << n  =>  a * POWER(2, n)
--   a >> n  =>  TRUNC(a / POWER(2, n))
--   a & b   =>  BITAND(a, b)
--   a | b   =>  a + b - BITAND(a, b)
--   ~a & b  =>  b - BITAND(a, b)     (clear bits of a in b)
--
-- Bit-mask constants:
--   ZOOM_MASK    = 139611588448485376 = 31 << 52
--   UNUSED_MASK  = 4503599627370495   = 0xFFFFFFFFFFFFF

CREATE OR REPLACE FUNCTION @@ORA_SCHEMA@@.QUADBIN_TOPARENT
(quadbin NUMBER, resolution NUMBER)
RETURN NUMBER
AS
    ZOOM_BITS    CONSTANT NUMBER := 31;
    ZOOM_SHIFT   CONSTANT NUMBER := 52;
    UNUSED_MASK  CONSTANT NUMBER := 4503599627370495;
    MIN_RES      CONSTANT NUMBER := 0;
    MAX_RES      CONSTANT NUMBER := 26;

    v_current_res NUMBER;
    v_zoom_mask   NUMBER;
    v_cleared     NUMBER;
    v_result      NUMBER;
BEGIN
    IF quadbin IS NULL OR resolution IS NULL THEN
        RETURN NULL;
    END IF;

    IF resolution < MIN_RES OR resolution > MAX_RES THEN
        RETURN NULL;
    END IF;

    -- Extract current resolution: bits 52-56
    v_current_res := BITAND(TRUNC(quadbin / POWER(2, ZOOM_SHIFT)), ZOOM_BITS);

    -- Target resolution must be <= current resolution
    IF resolution > v_current_res THEN
        RETURN NULL;
    END IF;

    -- Clear zoom bits: quadbin & ~(31 << 52)
    -- Equivalent to: quadbin - BITAND(quadbin, 31 << 52)
    v_zoom_mask := ZOOM_BITS * POWER(2, ZOOM_SHIFT);
    v_cleared := quadbin - BITAND(quadbin, v_zoom_mask);

    -- Set new zoom and OR in unused bits mask
    -- result = v_cleared | (resolution << 52) | (UNUSED_MASK >> (resolution * 2))
    v_result := v_cleared;

    -- v_result |= (resolution << 52)
    v_result := v_result
        + resolution * POWER(2, ZOOM_SHIFT)
        - BITAND(v_result, resolution * POWER(2, ZOOM_SHIFT));

    -- v_result |= TRUNC(UNUSED_MASK / POWER(2, resolution * 2))
    v_result := v_result
        + TRUNC(UNUSED_MASK / POWER(2, resolution * 2))
        - BITAND(v_result, TRUNC(UNUSED_MASK / POWER(2, resolution * 2)));

    RETURN v_result;
END;
/
