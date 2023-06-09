----------------------------
-- Copyright (C) 2022 CARTO
----------------------------

CREATE OR REPLACE FUNCTION `@@BQ_DATASET@@.QUADBIN_TOCHILDREN`
(cell INT64, children_resolution INT64)
RETURNS ARRAY<INT64>
AS ((
    IF(children_resolution < 0 OR children_resolution > 26 OR children_resolution < ((children_resolution >> 52) & 0x1F),
        ERROR('Invalid resolution'),
        (
            WITH
            __constants AS (
                SELECT
                  ~(0x1F << 52) AS zoom_level_mask,
                    ((cell >> 52) & 0x1F) AS tile_z
            ),
            __block_constants AS (
              SELECT
                (children_resolution - tile_z) AS resolution_diff,
                (1 << ((children_resolution - tile_z) << 1)) AS block_range,
                (52 - (children_resolution << 1)) AS block_shift
              FROM
                  __constants
            ),
            __childbase_constants AS (
                SELECT
                    ((cell & zoom_level_mask) | (children_resolution << 52)) & ~((block_range - 1) << block_shift)
                        AS child_base
                FROM
                    __block_constants,
                    __constants
            )
            SELECT
                ARRAY(
                    SELECT
                        child_base | (block << block_shift)
                    FROM
                        __block_constants,
                        __childbase_constants,
                        UNNEST(GENERATE_ARRAY(0, block_range - 1)) AS block
                )
        )
    )
))
