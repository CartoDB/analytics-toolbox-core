----------------------------
-- Copyright (C) 2021 CARTO
----------------------------

CREATE OR REPLACE FUNCTION @@SF_SCHEMA@@._QUADINT_BOUNDARY
(quadint STRING)
RETURNS STRING
LANGUAGE JAVASCRIPT
IMMUTABLE
AS $$
    if (!QUADINT) {
        throw new Error('NULL argument passed to UDF');
    }

    @@SF_LIBRARY_QUADKEY@@

    const geojson = quadkeyLib.quadintToGeoJSON(QUADINT);
    return JSON.stringify(geojson);
$$;

CREATE OR REPLACE SECURE FUNCTION @@SF_SCHEMA@@.QUADINT_BOUNDARY
(quadint BIGINT)
RETURNS GEOGRAPHY
IMMUTABLE
AS $$
    TRY_TO_GEOGRAPHY(@@SF_SCHEMA@@._QUADINT_BOUNDARY(CAST(QUADINT AS STRING)))
$$;
