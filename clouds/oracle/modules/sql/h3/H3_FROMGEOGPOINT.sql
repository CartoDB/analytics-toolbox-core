----------------------------
-- Copyright (C) 2026 CARTO
----------------------------

-- Input geometry must be a WGS84 (SRID 4326) point. The function does
-- not auto-transform: a point with an explicit SRID other than 4326
-- returns NULL. A NULL SRID is accepted and treated as WGS84, matching
-- the convention used by SDO_UTIL.FROM_WKTGEOMETRY.
CREATE OR REPLACE FUNCTION @@ORA_SCHEMA@@.H3_FROMGEOGPOINT
(
    point SDO_GEOMETRY, resolution NUMBER
)
RETURN VARCHAR2
DETERMINISTIC
IS
    MIN_RESOLUTION CONSTANT PLS_INTEGER := 0;
    MAX_RESOLUTION CONSTANT PLS_INTEGER := 15;
    POINT_GTYPE CONSTANT PLS_INTEGER := 1;
    SRID_WGS84 CONSTANT PLS_INTEGER := 4326;
    h3_raw RAW(8);
    wgs84_point SDO_GEOMETRY;
BEGIN
    IF point IS NULL OR resolution IS NULL THEN
        RETURN NULL;
    END IF;
    IF resolution < MIN_RESOLUTION OR resolution > MAX_RESOLUTION THEN
        RETURN NULL;
    END IF;
    IF point.GET_GTYPE() != POINT_GTYPE THEN
        RETURN NULL;
    END IF;
    -- Reject explicit non-WGS84 SRIDs; accept NULL SRID (caller's
    -- intent is WGS84, e.g. SDO_UTIL.FROM_WKTGEOMETRY output) and
    -- re-tag it for SDO_UTIL.H3_KEY which requires an explicit SRID.
    IF point.SDO_SRID IS NOT NULL AND point.SDO_SRID != SRID_WGS84 THEN
        RETURN NULL;
    END IF;
    IF point.SDO_SRID IS NULL THEN
        wgs84_point := SDO_GEOMETRY(
            point.SDO_GTYPE, SRID_WGS84,
            point.SDO_POINT, point.SDO_ELEM_INFO, point.SDO_ORDINATES
        );
    ELSE
        wgs84_point := point;
    END IF;

    h3_raw := SDO_UTIL.H3_KEY(wgs84_point, resolution);
    RETURN LOWER(LTRIM(RAWTOHEX(h3_raw), '0'));
EXCEPTION
    WHEN OTHERS THEN
        RETURN NULL;
END H3_FROMGEOGPOINT;
/
