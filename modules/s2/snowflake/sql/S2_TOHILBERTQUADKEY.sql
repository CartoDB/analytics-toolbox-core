----------------------------
-- Copyright (C) 2021 CARTO
----------------------------

CREATE OR REPLACE FUNCTION _S2_TOHILBERTQUADKEY
(id STRING)
RETURNS STRING
LANGUAGE JAVASCRIPT
IMMUTABLE
AS $$
    if (!ID) {
        throw new Error('NULL argument passed to UDF');
    }

    @@SF_LIBRARY_CONTENT@@

    return s2Lib.idToKey(ID);
$$;

CREATE OR REPLACE SECURE FUNCTION S2_TOHILBERTQUADKEY
(id BIGINT)
RETURNS STRING
IMMUTABLE
AS $$
    _S2_TOHILBERTQUADKEY(CAST(ID AS STRING))
$$;