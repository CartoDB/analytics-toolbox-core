----------------------------
-- Copyright (C) 2021 CARTO
----------------------------

CREATE OR REPLACE FUNCTION @@PG_SCHEMA@@.H3_RESOLUTION(
    index VARCHAR(16)
)
RETURNS INT
AS
$BODY$
    if (!index) {
        return null;
    }

    @@PG_LIBRARY_H3@@

    if (!h3Lib.h3IsValid(index)) {
        return null;
    }

    return h3Lib.h3GetResolution(index);
$BODY$
LANGUAGE plv8 IMMUTABLE PARALLEL SAFE;
