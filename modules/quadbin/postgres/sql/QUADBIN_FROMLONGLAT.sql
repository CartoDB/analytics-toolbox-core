----------------------------
-- Copyright (C) 2022 CARTO
----------------------------

CREATE OR REPLACE FUNCTION _SAFE_QUADBIN_FROMLONGLAT(
  longitude DOUBLE PRECISION,
  latitude DOUBLE PRECISION,
  resolution INTEGER
)
RETURNS BIGINT
 AS
$BODY$
    SELECT CASE
    WHEN longitude IS NULL OR latitude IS NULL OR resolution IS NULL OR resolution < 0 OR resolution > 26
    THEN NULL
    ELSE
        (WITH
        __params AS (
            SELECT
                resolution AS z,
                GREATEST(-85.05, LEAST(85.05, latitude)) AS latitude
        ),
        __zxy AS (
            SELECT
                z,
                (FLOOR((1 << z) * ((longitude / 360.0) + 0.5)))::BIGINT & ((1 << z) - 1) AS x,
                (FLOOR((1 << z) * (0.5 - (LN(TAN(PI()/4.0 + latitude/2.0 * PI()/180.0)) / (2*PI())))))::BIGINT & ((1 << z) - 1) AS y
            FROM __params
        )
        SELECT @@PG_PREFIX@@carto.QUADBIN_FROMZXY(z, x::INT, y::INT)
        FROM __zxy)
    END
$BODY$
  LANGUAGE SQL;

CREATE OR REPLACE FUNCTION QUADBIN_FROMLONGLAT(
  longitude DOUBLE PRECISION,
  latitude DOUBLE PRECISION,
  resolution INTEGER
)
RETURNS BIGINT
 AS
$BODY$
BEGIN
    IF resolution < 0 OR resolution > 26 THEN
      RAISE EXCEPTION 'Invalid resolution %; should be between 0 and 26', resolution;
    END IF;

    RETURN @@PG_PREFIX@@carto._SAFE_QUADBIN_FROMLONGLAT(longitude, latitude, resolution);
END;
$BODY$
  LANGUAGE PLPGSQL;
