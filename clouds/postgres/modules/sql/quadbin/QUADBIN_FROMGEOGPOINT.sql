----------------------------
-- Copyright (C) 2022 CARTO
----------------------------

CREATE OR REPLACE FUNCTION @@PG_SCHEMA@@.QUADBIN_FROMGEOGPOINT(
    point GEOMETRY,
    resolution INT
)
RETURNS BIGINT
AS
$BODY$
    WITH
    __geom4326 AS (
        SELECT CASE ST_SRID(point)
          WHEN 0 THEN ST_SETSRID(point, 4326)
          ELSE ST_TRANSFORM(point, 4326)
        END AS geom
    )
    SELECT @@PG_SCHEMA@@.QUADBIN_FROMLONGLAT(ST_X(geom), ST_Y(geom), resolution)
    FROM __geom4326;
$BODY$
LANGUAGE sql IMMUTABLE PARALLEL SAFE;
