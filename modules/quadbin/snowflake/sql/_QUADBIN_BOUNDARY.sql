----------------------------
-- Copyright (C) 2022 CARTO
----------------------------

CREATE OR REPLACE FUNCTION _GET_QUADBIN_POLYGON
(index STRING)
RETURNS ARRAY
LANGUAGE JAVASCRIPT
IMMUTABLE
AS $$
    if (!INDEX) {
        return [];
    }

    @@SF_LIBRARY_CONTENT@@
    return quadbinLib.getQuadbinPolygon(INDEX);
$$;

CREATE OR REPLACE FUNCTION _GET_QUADBIN_POLYGON_1
(index STRING)
RETURNS STRING
LANGUAGE JAVASCRIPT
IMMUTABLE
AS $$
    if (!INDEX) {
        return [];
    }

    @@SF_LIBRARY_CONTENT@@
    const arrayPolygon = quadbinLib.getQuadbinPolygon(INDEX);
    return 'LINESTRING(' + 
        arrayPolygon[0] + ' ' arrayPolygon[1] ',' +
        arrayPolygon[2] + ' ' arrayPolygon[3] ',' +
        arrayPolygon[4] + ' ' arrayPolygon[5] ',' +
        arrayPolygon[6] + ' ' arrayPolygon[7] ',' +
        arrayPolygon[8] + ' ' arrayPolygon[9] ',' +
    ')';
$$;


CREATE OR REPLACE SECURE FUNCTION _QUADBIN_BOUNDARY_1
(quadbin BIGINT)
RETURNS GEOGRAPHY
IMMUTABLE
AS $$
    SELECT ST_MAKEPOLYGON(
        TRY_TO_GEOGRAPHY(_GET_QUADBIN_POLYGON_1(TO_VARCHAR(QUADBIN, 'xxxxxxxxxxxxxxxx')))
    )
$$;

CREATE OR REPLACE SECURE FUNCTION _QUADBIN_BOUNDARY
(quadbin BIGINT)
RETURNS GEOGRAPHY
IMMUTABLE
AS $$
    WITH array_polygon AS (
        SELECT _GET_QUADBIN_POLYGON(TO_VARCHAR(QUADBIN, 'xxxxxxxxxxxxxxxx')) p
    )
    SELECT ST_MAKEPOLYGON(
        TRY_TO_GEOGRAPHY(
            'LINESTRING(' ||
            GET(p, 0) || ' ' || GET(p, 1) || ',' ||
            GET(p, 2) || ' ' || GET(p, 3) || ',' ||
            GET(p, 4) || ' ' || GET(p, 5) || ',' ||
            GET(p, 6) || ' ' || GET(p, 7) || ',' ||
            GET(p, 8) || ' ' || GET(p, 9) ||
            ')'))
    FROM array_polygon
$$;
