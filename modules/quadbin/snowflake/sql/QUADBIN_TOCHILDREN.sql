----------------------------
-- Copyright (C) 2022 CARTO
----------------------------
CREATE OR REPLACE FUNCTION QUADBIN_TOCHILDREN
(quadbin INT, resolution INT)
RETURNS ARRAY
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
    SELECT _QUADBIN_FROMRANGE(xmin, ymin, xmax, ymax, resolution)
    FROM __ranges
$$;

CREATE OR REPLACE FUNCTION _QUADBIN_FROMRANGE
(xmin INT, ymin INT, xmax INT, ymax INT, resolution INT)
RETURNS ARRAY
AS $$
    SELECT ARRAY_AGG(QUADBIN_FROMZXY(resolution, xs.n, ys.n))
    FROM
        TABLE(_GENERATE_RANGE(xmin, xmax)) AS xs,
        TABLE(_GENERATE_RANGE(ymin, ymax)) AS ys
$$;