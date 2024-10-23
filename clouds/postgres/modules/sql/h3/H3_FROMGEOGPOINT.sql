--------------------------------
-- Copyright (C) 2023-2024 CARTO
--------------------------------

CREATE OR REPLACE FUNCTION @@PG_SCHEMA@@.H3_FROMGEOGPOINT(
    geog GEOMETRY,
    resolution INT
)
RETURNS VARCHAR(16)
AS
$BODY$
    SELECT CASE
        WHEN ST_NPOINTS(geog) = 1 THEN
            @@PG_SCHEMA@@.H3_FROMLONGLAT(ST_X(geog), ST_Y(geog), resolution)
        ELSE
            NULL
    END
$BODY$
LANGUAGE sql IMMUTABLE PARALLEL SAFE;

CREATE OR REPLACE FUNCTION @@PG_SCHEMA@@.H3_FROMGEOPOINT(
    geo GEOMETRY,
    resolution INT
)
RETURNS VARCHAR(16)
AS
$BODY$
    SELECT @@PG_SCHEMA@@.H3_FROMGEOGPOINT(geo, resolution)
$BODY$
LANGUAGE sql IMMUTABLE PARALLEL SAFE;
