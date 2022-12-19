----------------------------
-- Copyright (C) 2022 CARTO
----------------------------

CREATE OR REPLACE FUNCTION @@PG_SCHEMA@@.__CONV_BASE10_BASE4(
    i BIGINT
)
RETURNS TEXT AS
$$
DECLARE
    result TEXT = '';
    digit INT;
BEGIN
    WHILE i > 0 LOOP
        digit = i % 4;
        result = digit::TEXT || result;
        i = i / 4;
    END LOOP;
    RETURN result;
END;
$$
LANGUAGE plpgsql;


CREATE OR REPLACE FUNCTION @@PG_SCHEMA@@.QUADBIN_TOQUADKEY(
    quadbin BIGINT
)
RETURNS TEXT
AS
$BODY$
  WITH __z AS (
      SELECT
        ((quadbin >> 52) & 31)::INT AS z
  ),
  __xy AS (
    SELECT
        z,
        ((quadbin & 4503599627370495) >> (52 - z * 2)) AS xy
    FROM __z
  )
  SELECT
    CASE
        WHEN z = 0 THEN ''
        ELSE
            LPAD(@@PG_SCHEMA@@.__CONV_BASE10_BASE4(xy), z, '0')
    END
  FROM __xy;
$BODY$
LANGUAGE sql IMMUTABLE PARALLEL SAFE;
