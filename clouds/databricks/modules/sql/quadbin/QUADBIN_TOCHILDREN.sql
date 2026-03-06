----------------------------
-- Copyright (C) 2026 CARTO
----------------------------

-- Returns all child quadbin cells at a given resolution using
-- bit manipulation to derive children from the parent's position.

CREATE OR REPLACE FUNCTION @@DB_SCHEMA@@.QUADBIN_TOCHILDREN
(quadbin BIGINT, resolution INT)
RETURNS ARRAY<BIGINT>
RETURN (
    IF(
        resolution IS NULL OR resolution < 0 OR resolution > 26
        OR resolution < CAST((quadbin >> 52) & CAST(31 AS BIGINT) AS INT),
        RAISE_ERROR('Invalid resolution'),
        (WITH __params AS (
            SELECT
                GREATEST(resolution - CAST((quadbin >> 52) & 31 AS INT), 0)
                AS res_diff
        ),

        __constants AS (
            SELECT
                ~(CAST(31 AS BIGINT) << 52) AS zoom_level_mask,
                (1 << (res_diff << 1)) AS block_range,
                (1 << res_diff) AS sqrt_block_range,
                (52 - (resolution << 1)) AS block_shift
            FROM __params
        ),

        __child_base AS (
            SELECT
                sqrt_block_range,
                block_shift,
                (
                    (quadbin & zoom_level_mask)
                    | (CAST(resolution AS BIGINT) << 52)
                )
                & ~(CAST(block_range - 1 AS BIGINT) << block_shift)
                AS child_base
            FROM __constants
        ),

        __children AS (
            SELECT
                child_base
                | (CAST(r * sqrt_block_range + c AS BIGINT) << block_shift)
                AS child
            FROM __child_base
                LATERAL VIEW EXPLODE(SEQUENCE(0, sqrt_block_range - 1)) t1 AS r
                LATERAL VIEW EXPLODE(SEQUENCE(0, sqrt_block_range - 1)) t2 AS c
        )

        SELECT COLLECT_LIST(child) FROM __children)
    )
);
