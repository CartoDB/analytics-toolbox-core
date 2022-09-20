----------------------------
-- Copyright (C) 2021 CARTO
----------------------------

CREATE OR REPLACE FUNCTION @@SF_SCHEMA@@._S2_TOHILBERTQUADKEY
(id STRING)
RETURNS STRING
LANGUAGE JAVASCRIPT
IMMUTABLE
AS $$
    if (!ID) {
        throw new Error('NULL argument passed to UDF');
    }

    @@SF_LIBRARY_S2@@

    return s2Lib.idToKey(ID);
$$;

CREATE OR REPLACE SECURE FUNCTION @@SF_SCHEMA@@.S2_TOHILBERTQUADKEY
(id BIGINT)
RETURNS STRING
IMMUTABLE
AS $$
    @@SF_SCHEMA@@._S2_TOHILBERTQUADKEY(CAST(ID AS STRING))
$$;
