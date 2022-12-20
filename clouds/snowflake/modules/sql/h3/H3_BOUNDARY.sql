----------------------------
-- Copyright (C) 2021 CARTO
----------------------------

CREATE OR REPLACE FUNCTION @@SF_SCHEMA@@._H3_BOUNDARY
(index STRING)
RETURNS STRING
LANGUAGE JAVASCRIPT
IMMUTABLE
AS $$
    if (!INDEX) {
        return null;
    }

    @@SF_LIBRARY_H3_BOUNDARY@@

    if (!h3BoundaryLib.h3IsValid(INDEX)) {
        return null;
    }

    const coords = h3BoundaryLib.h3ToGeoBoundary(INDEX, true);
    const uniqueCoords = h3BoundaryLib.removeDuplicates(coords);
    const polygonCoords = uniqueCoords.concat([uniqueCoords[0]]);
    return `POLYGON((${polygonCoords.map(c => `${c[0]} ${c[1]}`).join(',')}))`;
$$;

CREATE OR REPLACE SECURE FUNCTION @@SF_SCHEMA@@.H3_BOUNDARY
(index STRING)
RETURNS GEOGRAPHY
IMMUTABLE
AS $$
    TRY_TO_GEOGRAPHY(@@SF_SCHEMA@@._H3_BOUNDARY(INDEX))
$$;
