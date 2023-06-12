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
                          (1 << ((resolution - ((quadbin >> 52) & 0x1F)) << 1)) AS block_range,
                CAST(SQRT((1 << ((resolution - ((quadbin >> 52) & 0x1F)) << 1))) as int) AS sqrt_block_range,
                (52 - (resolution << 1)) AS block_shift
            ),
            __childbase_constants AS (
              SELECT
                ((quadbin & zoom_level_mask) | (resolution << 52)) & ~((block_range - 1) << block_shift)
                    AS child_base
              FROM
                __constants
            )
            SELECT
              ARRAY(
                SELECT
                    child_base | ((block_row * sqrt_block_range + block_column) << block_shift)
                FROM
                    __constants,
                    __childbase_constants,
                    UNNEST(GENERATE_ARRAY(0, sqrt_block_range - 1)) AS block_row,
                    UNNEST(GENERATE_ARRAY(0, sqrt_block_range - 1)) AS block_column
              )
        )
    )
))
