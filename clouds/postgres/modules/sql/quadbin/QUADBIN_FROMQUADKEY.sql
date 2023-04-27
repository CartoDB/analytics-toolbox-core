----------------------------
-- Copyright (C) 2022 CARTO
----------------------------

CREATE OR REPLACE FUNCTION @@PG_SCHEMA@@.__CONV_BASE4_BASE10(
    s TEXT
)
RETURNS BIGINT
AS
$BODY$
DECLARE
    result BIGINT = 0;
    digit INT;
    power INT = 1;
    i INT;
BEGIN
    FOR i IN 1 .. length(s) LOOP
        digit = substr(s, length(s) - i + 1, 1)::INT;
        result = result + digit * power;
        power = power * 4;
    END LOOP;
    RETURN result;
END;
$BODY$
LANGUAGE plpgsql IMMUTABLE PARALLEL SAFE;

CREATE OR REPLACE FUNCTION @@PG_SCHEMA@@.QUADBIN_FROMQUADKEY(
    quadkey TEXT
)
RETURNS BIGINT
AS
$BODY$
  WITH __inter AS (
      SELECT
        LENGTH(quadkey) AS z,
        @@PG_SCHEMA@@.__CONV_BASE4_BASE10(quadkey) AS xy
  )
  SELECT
      4611686018427387904
      | (1::BIGINT << 59)
      | (z::BIGINT << 52)
      | (xy::BIGINT << (52 - (z << 1)))
      | (4503599627370495 >> (z << 1))
  FROM __inter;
$BODY$
LANGUAGE sql IMMUTABLE PARALLEL SAFE;
