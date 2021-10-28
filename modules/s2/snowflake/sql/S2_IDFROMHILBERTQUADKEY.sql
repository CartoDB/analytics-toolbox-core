----------------------------
-- Copyright (C) 2021 CARTO
----------------------------

CREATE OR REPLACE FUNCTION _S2_IDFROMHILBERTQUADKEY
(quadkey STRING)
RETURNS STRING
LANGUAGE JAVASCRIPT
AS $$
    @@SF_LIBRARY_CONTENT@@
    
    if (!QUADKEY) {
        throw new Error('NULL argument passed to UDF');
    }

    return s2Lib.keyToId(QUADKEY);
$$;

CREATE OR REPLACE SECURE FUNCTION S2_IDFROMHILBERTQUADKEY
(quadkey STRING)
RETURNS BIGINT
AS $$
    CAST(_S2_IDFROMHILBERTQUADKEY(QUADKEY) AS BIGINT)
$$;