----------------------------
-- Copyright (C) 2022 CARTO
----------------------------

CREATE OR REPLACE FUNCTION @@PG_SCHEMA@@.QUADBIN_TOCHILDREN(
    quadbin BIGINT,
    resolution INT
)
RETURNS BIGINT[]
AS
$BODY$
    SELECT CASE
    WHEN resolution < 0 OR resolution > 26 OR resolution < ((quadbin >> 52) & 31)
    THEN @@PG_SCHEMA@@.__CARTO_ERROR('Invalid resolution')::BIGINT[]
    ELSE (
        WITH
        __constants AS (
            SELECT
                ~(31::bigint << 52) AS zoom_level_mask,
                (1::bigint << ((resolution - ((quadbin >> 52) & 31)::int) << 1)::int) AS block_range,
                 1::bigint <<  (resolution - ((quadbin >> 52) & 31)::int)             AS sqrt_block_range,
                (52 - (resolution << 1)) AS block_shift
        ),
        __childbase_constants AS (
            SELECT
                ((quadbin & zoom_level_mask) | (resolution::bigint << 52)) & ~((block_range - 1) << block_shift)
                    AS child_base
            FROM __constants
        )
        SELECT
            array_agg(child_base | ((block_row * sqrt_block_range + block_column) << block_shift))
        FROM
            __constants,
            __childbase_constants,
            generate_series(0, sqrt_block_range-1) as block_row,
            generate_series(0, sqrt_block_range-1) as block_column
        )
    END
$BODY$
LANGUAGE sql IMMUTABLE PARALLEL SAFE;
