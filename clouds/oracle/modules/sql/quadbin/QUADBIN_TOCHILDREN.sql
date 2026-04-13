----------------------------
-- Copyright (C) 2026 CARTO
----------------------------

-- Returns a JSON array of all child quadbin indices at the specified
-- (finer) resolution.  Each zoom level produces 4 children (quadtree),
-- so total = 4^(resolution - current_resolution).
--
-- Raises an error if resolution is outside [0,26] or less than the
-- current resolution of the input quadbin.
--
-- Oracle bit operation equivalents:
--   a << n  =>  a * POWER(2, n)
--   a >> n  =>  TRUNC(a / POWER(2, n))
--   a & b   =>  BITAND(a, b)
--   a | b   =>  a + b - BITAND(a, b)
--   ~a & b  =>  b - BITAND(a, b)
--
-- Bit-mask constants:
--   ZOOM_MASK    = 139611588448485376 = 31 << 52
--   UNUSED_MASK  = 4503599627370495   = 0xFFFFFFFFFFFFF

CREATE OR REPLACE FUNCTION @@ORA_SCHEMA@@.QUADBIN_TOCHILDREN
(quadbin NUMBER, resolution NUMBER)
RETURN CLOB
AS
    ZOOM_BITS    CONSTANT NUMBER := 31;
    ZOOM_SHIFT   CONSTANT NUMBER := 52;
    MIN_RES      CONSTANT NUMBER := 0;
    MAX_RES      CONSTANT NUMBER := 26;

    v_current_res    NUMBER;
    v_res_diff       NUMBER;
    v_zoom_mask      NUMBER;
    v_block_range    NUMBER;
    v_sqrt_range     NUMBER;
    v_block_shift    NUMBER;
    v_child_base     NUMBER;
    v_clear_mask     NUMBER;
    v_child          NUMBER;
    v_result         CLOB;
    v_first          BOOLEAN := TRUE;
    v_val            VARCHAR2(30);
BEGIN
    IF quadbin IS NULL OR resolution IS NULL THEN
        RETURN NULL;
    END IF;

    -- Extract current resolution
    v_current_res := BITAND(TRUNC(quadbin / POWER(2, ZOOM_SHIFT)), ZOOM_BITS);

    -- Validate resolution
    IF resolution < MIN_RES OR resolution > MAX_RES
       OR resolution < v_current_res THEN
        RAISE_APPLICATION_ERROR(-20001, 'Invalid resolution');
    END IF;

    v_res_diff := resolution - v_current_res;

    -- block_range = 1 << (res_diff * 2) = 4^res_diff (total children)
    v_block_range := POWER(2, v_res_diff * 2);

    -- sqrt_block_range = 1 << res_diff = 2^res_diff (children per axis)
    v_sqrt_range := POWER(2, v_res_diff);

    -- block_shift = 52 - (resolution * 2)
    v_block_shift := ZOOM_SHIFT - (resolution * 2);

    -- zoom_level_mask = ~(31 << 52)
    v_zoom_mask := ZOOM_BITS * POWER(2, ZOOM_SHIFT);

    -- child_base = ((quadbin & ~zoom_mask) | (resolution << 52))
    --              & ~((block_range - 1) << block_shift)
    v_child_base := quadbin - BITAND(quadbin, v_zoom_mask);
    v_child_base := v_child_base
        + resolution * POWER(2, ZOOM_SHIFT)
        - BITAND(v_child_base, resolution * POWER(2, ZOOM_SHIFT));

    -- Clear the child-position bits: & ~((block_range - 1) << block_shift)
    v_clear_mask := (v_block_range - 1) * POWER(2, v_block_shift);
    v_child_base := v_child_base - BITAND(v_child_base, v_clear_mask);

    -- Generate all children by iterating over row (r) and column (c)
    DBMS_LOB.CREATETEMPORARY(v_result, TRUE);
    DBMS_LOB.WRITEAPPEND(v_result, 1, '[');

    FOR r IN 0 .. v_sqrt_range - 1 LOOP
        FOR c IN 0 .. v_sqrt_range - 1 LOOP
            -- child = child_base | ((r * sqrt_range + c) << block_shift)
            v_child := v_child_base
                + (r * v_sqrt_range + c) * POWER(2, v_block_shift)
                - BITAND(
                    v_child_base,
                    (r * v_sqrt_range + c) * POWER(2, v_block_shift)
                );

            IF v_first THEN
                v_first := FALSE;
            ELSE
                DBMS_LOB.WRITEAPPEND(v_result, 1, ',');
            END IF;
            v_val := TO_CHAR(v_child);
            DBMS_LOB.WRITEAPPEND(v_result, LENGTH(v_val), v_val);
        END LOOP;
    END LOOP;

    DBMS_LOB.WRITEAPPEND(v_result, 1, ']');
    RETURN v_result;
END;
/
