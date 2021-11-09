----------------------------
-- Copyright (C) 2021 CARTO
----------------------------

CREATE OR REPLACE FUNCTION @@SF_PREFIX@@s2._HILBERTQUADKEY_FROMID
(id STRING)
RETURNS STRING
LANGUAGE JAVASCRIPT
IMMUTABLE
AS $$
    if (!ID) {
        throw new Error('NULL argument passed to UDF');
    }

    function setup() {
        @@SF_LIBRARY_CONTENT@@
        s2LibGlobal = s2Lib;
    }

    if (typeof(s2LibGlobal) === "undefined") {
        setup();
    }

    return s2LibGlobal.idToKey(ID);
$$;

CREATE OR REPLACE SECURE FUNCTION @@SF_PREFIX@@s2.HILBERTQUADKEY_FROMID
(id BIGINT)
RETURNS STRING
IMMUTABLE
AS $$
    @@SF_PREFIX@@s2._HILBERTQUADKEY_FROMID(CAST(ID AS STRING))
$$;