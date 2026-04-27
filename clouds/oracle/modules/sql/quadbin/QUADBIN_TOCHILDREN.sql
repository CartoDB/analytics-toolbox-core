----------------------------
-- Copyright (C) 2026 CARTO
----------------------------

-- Returns all child quadbin indices at the specified (finer) resolution,
-- as a pipelined QUADBIN_INDEX_ARRAY. Each zoom level produces 4 children
-- (quadtree), so total = 4^(resolution - current_resolution).
--
-- Consume via: SELECT COLUMN_VALUE FROM TABLE(QUADBIN_TOCHILDREN(idx, r))
--
-- Returns an empty pipeline (no rows) when the resolution is outside
-- [0, 26] or coarser than the input quadbin's own resolution. Matches the
-- NULL-on-invalid convention codified in .claude/rules/oracle.md.
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
RETURN @@ORA_SCHEMA@@.QUADBIN_INDEX_ARRAY PIPELINED
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
BEGIN
    IF quadbin IS NULL OR resolution IS NULL THEN
        RETURN;
    END IF;

    v_current_res := BITAND(TRUNC(quadbin / POWER(2, ZOOM_SHIFT)), ZOOM_BITS);

    -- Empty pipeline on out-of-range or coarser-than-input resolution
    IF resolution < MIN_RES OR resolution > MAX_RES
       OR resolution < v_current_res THEN
        RETURN;
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

    FOR r IN 0 .. v_sqrt_range - 1 LOOP
        FOR c IN 0 .. v_sqrt_range - 1 LOOP
            -- child = child_base | ((r * sqrt_range + c) << block_shift)
            v_child := v_child_base
                + (r * v_sqrt_range + c) * POWER(2, v_block_shift)
                - BITAND(
                    v_child_base,
                    (r * v_sqrt_range + c) * POWER(2, v_block_shift)
                );
            PIPE ROW(v_child);
        END LOOP;
    END LOOP;

    RETURN;
END;
/
