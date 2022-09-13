----------------------------
-- Copyright (C) 2022 CARTO
----------------------------

CREATE OR REPLACE FUNCTION @@PG_SCHEMA@@.QUADBIN_KRING(
    origin BIGINT,
    size INT
)
RETURNS BIGINT[]
AS
$BODY$
    SELECT CASE WHEN size IS NULL OR size < 0 THEN
      @@PG_SCHEMA@@.__CARTO_ERROR(FORMAT('Invalid input size "%s"', size))::BIGINT[]
    ELSE (
      WITH __zxy AS (
        SELECT @@PG_SCHEMA@@.QUADBIN_TOZXY(origin) AS tile
      )
      SELECT ARRAY_AGG(
          DISTINCT (@@PG_SCHEMA@@.QUADBIN_FROMZXY(
              (tile->>'z')::INT,
              MOD((tile->>'x')::INT + dx + (1 << (tile->>'z')::INT), (1 << (tile->>'z')::INT)),
              (tile->>'y')::INT + dy)
          )
      )
      FROM
        __zxy,
        GENERATE_SERIES(-size, size) AS dx,
        GENERATE_SERIES(-size, size) AS dy
      WHERE (tile->>'y')::INT+ dy >= 0 AND (tile->>'y')::INT + dy < (1 << (tile->>'z')::INT)
    )
    END;
$BODY$
LANGUAGE SQL IMMUTABLE PARALLEL SAFE;
