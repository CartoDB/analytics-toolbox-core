----------------------------
-- Copyright (C) 2022 CARTO
----------------------------

CREATE OR REPLACE FUNCTION `@@BQ_DATASET@@.QUADBIN_TOCHILDREN`
(quadbin INT64, resolution INT64)
RETURNS ARRAY<INT64>
AS ((
    IF(resolution < 0 OR resolution > 26 OR resolution < ((quadbin >> 52) & 0x1F),
        ERROR('Invalid resolution'), (
        WITH
        __zxy AS (
            SELECT `@@BQ_DATASET@@.QUADBIN_TOZXY`(quadbin) AS tile
        )
        SELECT ARRAY_AGG(`@@BQ_DATASET@@.QUADBIN_FROMZXY`(resolution, xs, ys))
        FROM
            __zxy,
            UNNEST(GENERATE_ARRAY(tile.x << (resolution - tile.z), ((tile.x + 1) << (resolution - tile.z)) - 1)) AS xs,
            UNNEST(GENERATE_ARRAY(tile.y << (resolution - tile.z), ((tile.y + 1) << (resolution - tile.z)) - 1)) AS ys
    ))
));