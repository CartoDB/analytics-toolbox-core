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
      WITH _zxy AS (
          SELECT @@PG_SCHEMA@@.QUADBIN_TOZXY(quadbin) AS tile
      )
      SELECT ARRAY_AGG(@@PG_SCHEMA@@.QUADBIN_FROMZXY(resolution, xs, ys))
      FROM _zxy,
        GENERATE_SERIES((tile->>'x')::INT << (resolution - (tile->>'z')::INT), (((tile->>'x')::INT + 1) << (resolution - (tile->>'z')::INT)) - 1) as xs,
        GENERATE_SERIES((tile->>'y')::INT << (resolution - (tile->>'z')::INT), (((tile->>'y')::INT + 1) << (resolution - (tile->>'z')::INT)) - 1) as ys
    )
    END
$BODY$
LANGUAGE SQL IMMUTABLE PARALLEL SAFE;
