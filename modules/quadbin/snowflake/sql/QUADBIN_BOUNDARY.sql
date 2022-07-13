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
        throw new Error('NULL argument passed to UDF');
    }

    @@SF_LIBRARY_CONTENT@@

    return quadbinLib.getQuadbinPolygon(INDEX);
$$;


CREATE OR REPLACE SECURE FUNCTION QUADBIN_BOUNDARY
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
