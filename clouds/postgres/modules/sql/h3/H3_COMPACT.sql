----------------------------
-- Copyright (C) 2023 CARTO
----------------------------

CREATE OR REPLACE FUNCTION @@PG_SCHEMA@@.H3_COMPACT(
    h3array VARCHAR(16)[]
)
RETURNS VARCHAR(16)[]
AS
$BODY$
    if (h3array == null) {
        return [];
    }

    @@PG_LIBRARY_H3@@

    return h3Lib.compact(h3array);
$BODY$
LANGUAGE plv8 IMMUTABLE PARALLEL SAFE;
