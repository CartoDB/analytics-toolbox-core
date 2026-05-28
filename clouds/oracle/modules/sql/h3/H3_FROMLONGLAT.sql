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

    point  SDO_GEOMETRY;
    h3_raw RAW(8);
BEGIN
    IF longitude IS NULL OR latitude IS NULL OR resolution IS NULL THEN
        RETURN NULL;
    END IF;
    IF resolution < MIN_RESOLUTION OR resolution > MAX_RESOLUTION THEN
        RETURN NULL;
    END IF;

    -- Pass coordinates straight through to the native H3_KEY. Any
    -- out-of-range or invalid input is caught by the EXCEPTION handler
    -- below and returned as NULL (NULL-on-invalid convention).
    point := SDO_GEOMETRY(
        2001, 4326,
        SDO_POINT_TYPE(longitude, latitude, NULL),
        NULL, NULL
    );
    h3_raw := SDO_UTIL.H3_KEY(point, resolution);
    RETURN LOWER(LTRIM(RAWTOHEX(h3_raw), '0'));
EXCEPTION
    WHEN OTHERS THEN
        RETURN NULL;
END H3_FROMLONGLAT;
/
