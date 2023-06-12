----------------------------
-- Copyright (C) 2022 CARTO
----------------------------

CREATE OR REPLACE FUNCTION `@@BQ_DATASET@@.QUADBIN_TOCHILDREN`
(quadbin INT64, resolution INT64)
RETURNS ARRAY<INT64>
AS ((
    IF(resolution < 0 OR resolution > 26 OR resolution < ((resolution >> 52) & 0x1F),
        ERROR('Invalid resolution'),
        (
            WITH
            __constants AS (
              SELECT
                ~(0x1F << 52) AS zoom_level_mask,
                ((quadbin >> 52) & 0x1F) AS parent_resolution
            ),
            __block_constants AS (
              SELECT
                (resolution - parent_resolution) AS resolution_diff,
                (1 << ((resolution - parent_resolution) << 1)) AS block_range,
                CAST(SQRT((1 << ((resolution - parent_resolution) << 1))) as int) AS sqrt_block_range,
                (52 - (resolution << 1)) AS block_shift
              FROM
                  __constants
            ),
            __childbase_constants AS (
              SELECT
                ((quadbin & zoom_level_mask) | (resolution << 52)) & ~((block_range - 1) << block_shift)
                    AS child_base
              FROM
                __block_constants,
                __constants
            ),
            __block_indexes AS (
                SELECT
                    (block_raw * sqrt_block_range + block_column) AS block_index
                FROM
                    __block_constants,
                    -- avoid to generate array from 0 to block_range that can be huge! =>
                    -- splitting it in rows and columns
                    UNNEST(GENERATE_ARRAY(0, sqrt_block_range - 1)) AS block_raw,
                    UNNEST(GENERATE_ARRAY(0, sqrt_block_range - 1)) AS block_column
            )
            SELECT
              ARRAY(
                SELECT
                    child_base | (block_index << block_shift)
                FROM
                    __block_constants,
                    __childbase_constants,
                    __block_indexes
              )
        )
    )
))
