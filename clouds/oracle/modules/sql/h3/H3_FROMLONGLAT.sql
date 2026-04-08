----------------------------
-- Copyright (C) 2026 CARTO
----------------------------

CREATE OR REPLACE FUNCTION @@ORA_SCHEMA@@.H3_FROMLONGLAT
(
    longitude NUMBER, latitude NUMBER, resolution NUMBER
)
RETURN VARCHAR2
DETERMINISTIC
IS
    MIN_RESOLUTION CONSTANT PLS_INTEGER := 0;
    MAX_RESOLUTION CONSTANT PLS_INTEGER := 15;
    DEGREES_CIRCLE CONSTANT NUMBER := 360;
    HALF_CIRCLE CONSTANT NUMBER := 180;
    MAX_LATITUDE CONSTANT NUMBER := 90;
    norm_lon NUMBER;
    norm_lat NUMBER;
    point SDO_GEOMETRY;
    h3_raw RAW(8);
BEGIN
    IF longitude IS NULL OR latitude IS NULL OR resolution IS NULL THEN
        RETURN NULL;
    END IF;
    IF resolution < MIN_RESOLUTION OR resolution > MAX_RESOLUTION THEN
        RETURN NULL;
    END IF;

    -- Normalize longitude to [-180, 180) range
    norm_lon := MOD(longitude + HALF_CIRCLE, DEGREES_CIRCLE);
    IF norm_lon < 0 THEN
        norm_lon := norm_lon + DEGREES_CIRCLE;
    END IF;
    norm_lon := norm_lon - HALF_CIRCLE;

    -- Normalize latitude to [-90, 90] range
    norm_lat := MOD(latitude + HALF_CIRCLE, DEGREES_CIRCLE);
    IF norm_lat < 0 THEN
        norm_lat := norm_lat + DEGREES_CIRCLE;
    END IF;
    norm_lat := norm_lat - HALF_CIRCLE;
    IF norm_lat > MAX_LATITUDE THEN
        norm_lat := HALF_CIRCLE - norm_lat;
    ELSIF norm_lat < -MAX_LATITUDE THEN
        norm_lat := -HALF_CIRCLE - norm_lat;
    END IF;

    point := SDO_GEOMETRY(
        2001, 4326,
        SDO_POINT_TYPE(norm_lon, norm_lat, NULL),
        NULL, NULL
    );
    h3_raw := SDO_UTIL.H3_KEY(point, resolution);
    RETURN LOWER(LTRIM(RAWTOHEX(h3_raw), '0'));
EXCEPTION
    WHEN OTHERS THEN
        RETURN NULL;
END H3_FROMLONGLAT;
/
