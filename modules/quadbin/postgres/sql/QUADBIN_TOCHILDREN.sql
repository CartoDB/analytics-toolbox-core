----------------------------
-- Copyright (C) 2022 CARTO
----------------------------

CREATE OR REPLACE FUNCTION QUADBIN_TOCHILDREN(
  quadbin BIGINT,
  resolution INT
)
RETURNS BIGINT[]
 AS
$BODY$
    WITH _zxy AS (
        SELECT @@PG_PREFIX@@carto.QUADBIN_TOZXY(quadbin) AS tile
    )
    SELECT ARRAY_AGG(jgoizueta_carto.QUADBIN_FROMZXY(resolution, xs, ys))
    FROM _zxy,
      generate_series((tile->>'x')::INT << (resolution - (tile->>'z')::INT), (((tile->>'x')::INT + 1) << (resolution - (tile->>'z')::INT)) - 1) as xs,
      generate_series((tile->>'y')::INT << (resolution - (tile->>'z')::INT), (((tile->>'y')::INT + 1) << (resolution - (tile->>'z')::INT)) - 1) as ys
$BODY$
  LANGUAGE SQL;
