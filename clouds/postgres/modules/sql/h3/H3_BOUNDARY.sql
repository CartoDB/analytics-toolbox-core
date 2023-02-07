----------------------------
-- Copyright (C) 2023 CARTO
----------------------------

CREATE OR REPLACE FUNCTION @@PG_SCHEMA@@.H3_BOUNDARY
(index VARCHAR(16))
RETURNS GEOGRAPHY
AS $$
    if (!index) {
        return null;
    }

    @@PG_LIBRARY_H3_BOUNDARY@@

    if (!h3BoundaryLib.h3IsValid(index)) {
        return null;
    }

    const coords = h3BoundaryLib.h3ToGeoBoundary(index, true);
    const uniqueCoords = h3BoundaryLib.removeNextDuplicates(coords);
    return `POLYGON((${uniqueCoords.map(c => `${c[0]} ${c[1]}`).join(',')}))`;
$$ LANGUAGE plv8 IMMUTABLE PARALLEL SAFE;
