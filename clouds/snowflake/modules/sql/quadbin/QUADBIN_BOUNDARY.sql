----------------------------
-- Copyright (C) 2022 CARTO
----------------------------

CREATE OR REPLACE FUNCTION @@SF_SCHEMA@@._GET_QUADBIN_POLYGON
(index STRING)
RETURNS STRING
LANGUAGE JAVASCRIPT
IMMUTABLE
AS $$
    if (!INDEX) {
        return [];
    }

    @@SF_LIBRARY_QUADBIN@@

    const arrayPolygon = quadbinLib.getQuadbinPolygon(INDEX);
    return 'LINESTRING(' +
        arrayPolygon[0] + ' ' + arrayPolygon[1] + ',' +
        arrayPolygon[2] + ' ' + arrayPolygon[3] + ',' +
        arrayPolygon[4] + ' ' + arrayPolygon[5] + ',' +
        arrayPolygon[6] + ' ' + arrayPolygon[7] + ',' +
        arrayPolygon[8] + ' ' + arrayPolygon[9] +
    ')';
$$;


CREATE OR REPLACE SECURE FUNCTION @@SF_SCHEMA@@.QUADBIN_BOUNDARY
(quadbin BIGINT)
RETURNS GEOGRAPHY
IMMUTABLE
AS $$
    SELECT ST_MAKEPOLYGON(
        TRY_TO_GEOGRAPHY(@@SF_SCHEMA@@._GET_QUADBIN_POLYGON(TO_VARCHAR(QUADBIN, 'xxxxxxxxxxxxxxxx')))
    )
$$;
