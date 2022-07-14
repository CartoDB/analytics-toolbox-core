----------------------------
-- Copyright (C) 2022 CARTO
----------------------------

CREATE OR REPLACE FUNCTION _QUADBIN_FROMZXY
(_z DOUBLE, _x DOUBLE, _y DOUBLE)
RETURNS STRING
LANGUAGE JAVASCRIPT
IMMUTABLE
AS $$

    @@SF_LIBRARY_CONTENT@@

    const tile = {
        z: Number(_Z), 
        x: Number(_X), 
        y: Number(_Y)
    };

    return quadbinLib.tileToQuadbin(tile);
$$;

CREATE OR REPLACE FUNCTION QUADBIN_FROMZXY
(_z INT, _x INT, _y INT)
RETURNS BIGINT
IMMUTABLE
AS $$
    _QUADBIN_STRING_TOINT(
        _QUADBIN_FROMZXY(_Z, _X, _Y)
    )
$$;