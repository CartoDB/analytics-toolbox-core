----------------------------
-- Copyright (C) 2022 CARTO
----------------------------

CREATE OR REPLACE FUNCTION @@SF_SCHEMA@@._QUADBIN_FROMZXY
(_z DOUBLE, _x DOUBLE, _y DOUBLE)
RETURNS STRING
LANGUAGE JAVASCRIPT
IMMUTABLE
AS $$

    @@SF_LIBRARY_QUADBIN@@

    const tile = {
        z: Number(_Z),
        x: Number(_X),
        y: Number(_Y)
    };

    return quadbinLib.tileToQuadbin(tile);
$$;

CREATE OR REPLACE FUNCTION @@SF_SCHEMA@@.QUADBIN_FROMZXY
(_z INT, _x INT, _y INT)
RETURNS BIGINT
IMMUTABLE
AS $$
    @@SF_SCHEMA@@._QUADBIN_STRING_TOINT(
       @@SF_SCHEMA@@._QUADBIN_FROMZXY(_Z, _X, _Y)
    )
$$;