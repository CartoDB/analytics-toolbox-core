----------------------------
-- Copyright (C) 2023 CARTO
----------------------------

CREATE OR REPLACE FUNCTION @@PG_SCHEMA@@.H3_ISVALID(
    index VARCHAR(16)
)
RETURNS BOOLEAN
AS
$BODY$
    if (!index) {
        return false;
    }

    @@PG_LIBRARY_H3@@

    return h3Lib.h3IsValid(index);
$BODY$
LANGUAGE plv8 IMMUTABLE PARALLEL SAFE;
