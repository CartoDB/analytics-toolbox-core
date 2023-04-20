----------------------------
-- Copyright (C) 2023 CARTO
----------------------------

CREATE OR REPLACE FUNCTION @@PG_SCHEMA@@.H3_CENTER(
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

    const center = h3Lib.h3ToGeo(index);
    return `POINT(${center[1]} ${center[0]})`;
$BODY$
LANGUAGE plv8 IMMUTABLE PARALLEL SAFE;
