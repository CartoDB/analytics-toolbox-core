----------------------------
-- Copyright (C) 2021 CARTO
----------------------------

CREATE OR REPLACE FUNCTION @@SF_PREFIX@@s2._HILBERTQUADKEY_FROMID
(id STRING)
RETURNS STRING
LANGUAGE JAVASCRIPT
AS $$
    @@SF_LIBRARY_CONTENT@@
    
    if (!ID) {
        throw new Error('NULL argument passed to UDF');
    }

    return s2Lib.idToKey(ID);
$$;

CREATE OR REPLACE SECURE FUNCTION @@SF_PREFIX@@s2.HILBERTQUADKEY_FROMID
(id BIGINT)
RETURNS STRING
AS $$
    @@SF_PREFIX@@s2._HILBERTQUADKEY_FROMID(CAST(ID AS STRING))
$$;