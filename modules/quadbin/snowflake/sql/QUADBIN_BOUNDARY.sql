----------------------------
-- Copyright (C) 2022 CARTO
----------------------------

CREATE OR REPLACE FUNCTION _GET_QUADBIN_POLYGON
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
        arrayPolygon[0] + ' ' + arrayPolygon[1] + ',' +
        arrayPolygon[2] + ' ' + arrayPolygon[3] + ',' +
        arrayPolygon[4] + ' ' + arrayPolygon[5] + ',' +
        arrayPolygon[6] + ' ' + arrayPolygon[7] + ',' +
        arrayPolygon[8] + ' ' + arrayPolygon[9] +
    ')';
$$;


CREATE OR REPLACE SECURE FUNCTION QUADBIN_BOUNDARY
(quadbin BIGINT)
RETURNS GEOGRAPHY
IMMUTABLE
AS $$
    SELECT ST_MAKEPOLYGON(
        TRY_TO_GEOGRAPHY(_GET_QUADBIN_POLYGON(TO_VARCHAR(QUADBIN, 'xxxxxxxxxxxxxxxx')))
    )
$$;
