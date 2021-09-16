----------------------------
-- Copyright (C) 2021 CARTO
----------------------------

CREATE OR REPLACE FUNCTION @@RS_PREFIX@@constructors._MAKEELLIPSE
(centerPoint VARCHAR(MAX), xSemiAxis FLOAT8, ySemiAxis FLOAT8, angle FLOAT8, units VARCHAR(10), steps INT)
RETURNS VARCHAR(MAX)
IMMUTABLE
AS $$
    from @@RS_PREFIX@@constructorsLib import ellipse
    import geojson

    if centerPoint is None or xSemiAxis is None or ySemiAxis is None or angle is None or units is None or steps is None:
        return None

    geom_options = {}
    geom_options['angle'] = angle
    geom_options['steps'] = steps
    geom_options['units'] = units
    result_geojson = make_ellipse(
        center=geojson.loads(centerPoint),
        x_semi_axis=xSemiAxis,
        y_semi_axis=ySemiAxis,
        options=geom_options,
    )
    return str(result_geojson['geometry'])
$$ LANGUAGE plpythonu;

CREATE OR REPLACE FUNCTION @@RS_PREFIX@@constructors.ST_MAKEELLIPSE
(GEOMETRY, FLOAT8, FLOAT8)
-- (center, xSemiAxis, ySemiAxis)
RETURNS VARCHAR(MAX)
-- RETURNS GEOMETRY
IMMUTABLE
AS $$
    SELECT @@RS_PREFIX@@constructors._MAKEELLIPSE(ST_ASGEOJSON($1)::VARCHAR(MAX), $2, $3, 0, 'kilometers', 64)
    -- SELECT ST_GEOMFROMGEOJSON(@@RS_PREFIX@@constructors._MAKEELLIPSE(ST_ASGEOJSON($1)::VARCHAR(MAX), $2, $3, 0, 'kilometers', 64))
$$ LANGUAGE sql;

CREATE OR REPLACE FUNCTION @@RS_PREFIX@@constructors.ST_MAKEELLIPSE
(GEOMETRY, FLOAT8, FLOAT8, FLOAT8)
-- (center, xSemiAxis, ySemiAxis, angle)
RETURNS VARCHAR(MAX)
-- RETURNS GEOMETRY
IMMUTABLE
AS $$
    SELECT @@RS_PREFIX@@constructors._MAKEELLIPSE(ST_ASGEOJSON($1)::VARCHAR(MAX), $2, $3, $4, 'kilometers', 64)
    -- SELECT ST_GEOMFROMGEOJSON(@@RS_PREFIX@@constructors._MAKEELLIPSE(ST_ASGEOJSON($1)::VARCHAR(MAX), $2, $3, $4, 'kilometers', 64))
$$ LANGUAGE sql;

CREATE OR REPLACE FUNCTION @@RS_PREFIX@@constructors.ST_MAKEELLIPSE
(GEOMETRY, FLOAT8, FLOAT8, FLOAT8, VARCHAR(10))
-- (center, xSemiAxis, ySemiAxis, angle, units)
RETURNS VARCHAR(MAX)
-- RETURNS GEOMETRY
IMMUTABLE
AS $$
    SELECT @@RS_PREFIX@@constructors._MAKEELLIPSE(ST_ASGEOJSON($1)::VARCHAR(MAX), $2, $3, $4, $5, 64)
    -- SELECT ST_GEOMFROMGEOJSON(@@RS_PREFIX@@constructors._MAKEELLIPSE(ST_ASGEOJSON($1)::VARCHAR(MAX), $2, $3, $4, $5, 64))
$$ LANGUAGE sql;

CREATE OR REPLACE FUNCTION @@RS_PREFIX@@constructors.ST_MAKEELLIPSE
(GEOMETRY, FLOAT8, FLOAT8, FLOAT8, VARCHAR(10), INT)
-- (center, xSemiAxis, ySemiAxis, angle, units, steps)
RETURNS VARCHAR(MAX)
-- RETURNS GEOMETRY
IMMUTABLE
AS $$
    SELECT @@RS_PREFIX@@constructors._MAKEELLIPSE(ST_ASGEOJSON($1)::VARCHAR(MAX), $2, $3, $4, $5, $6)
    -- SELECT ST_GEOMFROMGEOJSON(@@RS_PREFIX@@constructors._MAKEELLIPSE(ST_ASGEOJSON($1)::VARCHAR(MAX), $2, $3, $4, $5, $6))
$$ LANGUAGE sql;
