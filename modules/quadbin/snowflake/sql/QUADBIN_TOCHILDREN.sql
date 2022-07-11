----------------------------
-- Copyright (C) 2022 CARTO
----------------------------
CREATE OR REPLACE FUNCTION QUADBIN_TOCHILDREN
(quadbin BIGINT, resolution INT)
RETURNS ARRAY
IMMUTABLE
AS $$
WITH
    __zxy AS (
        SELECT
            QUADBIN_TOZXY(quadbin) AS tile
    ),
    __ranges AS (
    SELECT
        bitshiftleft(tile:x, (resolution - tile:z)) AS xmin,
        bitshiftleft((tile:x + 1), (resolution - tile:z)) - 1 as xmax,
        bitshiftleft(tile:y, (resolution - tile:z)) as ymin,
        bitshiftleft((tile:y + 1), (resolution - tile:z)) - 1 as ymax
    FROM __zxy
    )
    SELECT ARRAY_AGG(QUADBIN_FROMZXY(resolution, xs.VALUE, ys.VALUE))
    FROM __ranges,
        TABLE(FLATTEN(_GENERATE_RANGE(xmin, xmax))) AS xs,
        TABLE(FLATTEN(_GENERATE_RANGE(ymin, ymax))) AS ys
$$;