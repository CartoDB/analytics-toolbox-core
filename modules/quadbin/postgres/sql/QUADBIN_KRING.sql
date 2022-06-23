----------------------------
-- Copyright (C) 2022 CARTO
----------------------------

CREATE OR REPLACE FUNCTION QUADBIN_KRING(
  origin BIGINT,
  size INT
)
RETURNS BIGINT[]
 AS
$BODY$
    SELECT CASE WHEN size IS NULL OR size < 0 THEN
      __CARTO_ERROR(FORMAT('Invalid input size "%s"', size))::BIGINT[]
    ELSE (
      WITH __zxy AS (
        SELECT @@PG_PREFIX@@carto.QUADBIN_TOZXY(origin) AS tile
      )
      SELECT ARRAY_AGG(
          DISTINCT (@@PG_PREFIX@@carto.QUADBIN_FROMZXY(
              (tile->>'z')::INT,
              MOD((tile->>'x')::INT + dx + (1 << (tile->>'z')::INT), (1 << (tile->>'z')::INT)),
              (tile->>'y')::INT + dy)
          )
      )
      FROM
        __zxy, generate_series(-size, size) AS dx, generate_series(-size, size) AS dy
      WHERE (tile->>'y')::INT+ dy >= 0 AND (tile->>'y')::INT + dy < (1 << (tile->>'z')::INT)
    )
    END;
$BODY$
  LANGUAGE SQL;
