----------------------------
-- Copyright (C) 2022 CARTO
----------------------------

CREATE OR REPLACE FUNCTION @@PG_SCHEMA@@.QUADBIN_KRING_DISTANCES(
  origin BIGINT,
  size INT
)
RETURNS JSON[]
 AS
$BODY$
    SELECT CASE WHEN size IS NULL OR size < 0 THEN
      @@PG_SCHEMA@@.__CARTO_ERROR(FORMAT('Invalid input size "%s"', size))::JSON[]
    ELSE (
      WITH __zxy AS (
        SELECT @@PG_SCHEMA@@.QUADBIN_TOZXY(origin) AS tile
      ),
      __t AS (
          SELECT
              @@PG_SCHEMA@@.QUADBIN_FROMZXY(
                  (tile->>'z')::INT,
                  MOD((tile->>'x')::INT + dx + (1 << (tile->>'z')::INT),
                  (1 << (tile->>'z')::INT)),
                  (tile->>'y')::INT + dy
              ) __index,
              GREATEST(ABS(dx), ABS(dy)) __distance -- Chebychev distance
          FROM
              __zxy,
              GENERATE_SERIES(-size, size) AS dx,
              GENERATE_SERIES(-size, size) AS dy
          WHERE (tile->>'y')::INT + dy >= 0 AND (tile->>'y')::INT + dy < (1 << (tile->>'z')::INT)
      ),
      __t_agg AS (
          SELECT
              __index,
              MIN(__distance) AS __distance
          FROM __t
          GROUP BY __index
      )
      SELECT ARRAY_AGG(JSON_BUILD_OBJECT('index', __index, 'distance', __distance))
      FROM __t_agg
    )
    END;
$BODY$
  LANGUAGE SQL IMMUTABLE PARALLEL SAFE;
