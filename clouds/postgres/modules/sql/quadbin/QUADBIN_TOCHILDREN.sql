----------------------------
-- Copyright (C) 2022 CARTO
----------------------------

CREATE OR REPLACE FUNCTION @@PG_SCHEMA@@.QUADBIN_TOCHILDREN(
    cell BIGINT,
    children_resolution INT
)
RETURNS BIGINT[]
AS
$BODY$
    SELECT CASE
    WHEN children_resolution < 0 OR children_resolution > 26 OR children_resolution < ((cell >> 52) & 31)
    THEN @@PG_SCHEMA@@.__CARTO_ERROR('Invalid resolution')::BIGINT[]
    ELSE (
        WITH
        __0xValues as (
            select
                31 as zoom_shifted_mask  -- decimal of 0x1F
        ),
        __constants AS (
            SELECT
                ~(zoom_shifted_mask::bigint << 52) AS zoom_level_mask,
                ((cell >> 52) & zoom_shifted_mask)::int AS tile_z
            FROM __0xValues
        ),
        __block_constants AS (
            SELECT
            (children_resolution - tile_z) AS resolution_diff,
            (1::bigint << ((children_resolution - tile_z) << 1)::int) AS block_range,
            (52 - (children_resolution << 1)) AS block_shift
            FROM __constants
        ),
        __childbase_constants AS (
            SELECT
                ((cell & zoom_level_mask) | (children_resolution::bigint << 52)) & ~((block_range - 1) << block_shift)
                    AS child_base
            FROM __block_constants,
                __constants
        )
        SELECT
            array_agg(child_base | (block << block_shift))
        FROM
            __block_constants,
            __childbase_constants,
            generate_series(0, block_range-1) as block
        )
    END
$BODY$
LANGUAGE sql IMMUTABLE PARALLEL SAFE;
