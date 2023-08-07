----------------------------
-- Copyright (C) 2023 CARTO
----------------------------

CREATE OR REPLACE FUNCTION @@PG_SCHEMA@@.H3_BOUNDARY(
    index VARCHAR(16)
)
RETURNS GEOMETRY
AS
$BODY$
    if (!index) {
        return null;
    }

    @@PG_LIBRARY_H3@@

    if (!h3Lib.h3IsValid(index)) {
        return null;
    }

    const coords = h3Lib.h3ToGeoBoundary(index, true);
    const uniqueCoords = h3Lib.removeNextDuplicates(coords);
    return `SRID=4326;POLYGON((${uniqueCoords.map(c => `${c[0]} ${c[1]}`).join(',')}))`;
$BODY$
LANGUAGE plv8 IMMUTABLE PARALLEL SAFE;
