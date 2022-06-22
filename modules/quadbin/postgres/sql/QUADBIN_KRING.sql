----------------------------
-- Copyright (C) 2022 CARTO
----------------------------

CREATE OR REPLACE FUNCTION _SAFE_QUADBIN_KRING(
  origin BIGINT,
  size INT
)
RETURNS BIGINT[]
 AS
$BODY$
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
    WHERE (tile->>'y')::INT+ dy >= 0 AND (tile->>'y')::INT + dy < (1 << (tile->>'z')::INT);
$BODY$
  LANGUAGE SQL;

CREATE OR REPLACE FUNCTION QUADBIN_KRING(
  origin BIGINT,
  size INT
)
RETURNS BIGINT[]
 AS
$BODY$
BEGIN
    IF size IS NULL OR size < 0 THEN
      RAISE EXCEPTION 'Invalid input size %', size;
    END IF;

    IF NOT @@PG_PREFIX@@carto.QUADBIN_ISVALID(origin) THEN
      RAISE EXCEPTION 'Invalid origin';
    END IF;

    RETURN @@PG_PREFIX@@carto._SAFE_QUADBIN_KRING(origin, size);
END;
$BODY$
  LANGUAGE PLPGSQL;
