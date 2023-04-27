----------------------------
-- Copyright (C) 2023 CARTO
----------------------------

CREATE OR REPLACE FUNCTION @@PG_SCHEMA@@.H3_UNCOMPACT
(h3array VARCHAR(16)[], resolution INT)
RETURNS VARCHAR(16)[]
AS
$BODY$
    if (h3array == null || resolution == null || resolution < 0 || resolution > 15) {
        return [];
    }

    @@PG_LIBRARY_H3@@

    return h3Lib.uncompact(h3array, Number(resolution));
$BODY$
LANGUAGE plv8 IMMUTABLE PARALLEL SAFE;
