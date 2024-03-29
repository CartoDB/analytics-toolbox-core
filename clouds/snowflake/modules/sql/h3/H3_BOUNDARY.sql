----------------------------
-- Copyright (C) 2021 CARTO
----------------------------
-- TODO: Re-implement this using SF's native H3_CELL_TO_BOUNDARY when they improve performance
-- Shortcut story/chore ID: 398796

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
    const uniqueCoords = h3BoundaryLib.removeNextDuplicates(coords);
    return `POLYGON((${uniqueCoords.map(c => `${c[0]} ${c[1]}`).join(',')}))`;
$$;

CREATE OR REPLACE SECURE FUNCTION @@SF_SCHEMA@@.H3_BOUNDARY
(index STRING)
RETURNS GEOGRAPHY
IMMUTABLE
AS $$
    TRY_TO_GEOGRAPHY(@@SF_SCHEMA@@._H3_BOUNDARY(INDEX))
$$;
