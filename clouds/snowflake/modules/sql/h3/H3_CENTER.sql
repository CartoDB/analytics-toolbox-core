----------------------------
-- Copyright (C) 2023 CARTO
----------------------------

CREATE OR REPLACE FUNCTION @@SF_SCHEMA@@._H3_CENTER
(index STRING)
RETURNS STRING
LANGUAGE JAVASCRIPT
IMMUTABLE
AS $$
    if (!INDEX) {
        return null;
    }

    @@SF_LIBRARY_H3_CENTER@@

    if (!h3CenterLib.h3IsValid(INDEX)) {
        return null;
    }

    const center = h3CenterLib.h3ToGeo(INDEX);
    return `POINT(${center[1]} ${center[0]})`;
$$;

CREATE OR REPLACE SECURE FUNCTION @@SF_SCHEMA@@.H3_CENTER
(index STRING)
RETURNS GEOGRAPHY
IMMUTABLE
AS $$
    TRY_TO_GEOGRAPHY(@@SF_SCHEMA@@._H3_CENTER(INDEX))
$$;
