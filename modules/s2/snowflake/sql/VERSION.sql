----------------------------
-- Copyright (C) 2021 CARTO
----------------------------

CREATE OR REPLACE SECURE FUNCTION @@SF_PREFIX@@s2.VERSION
()
RETURNS STRING
LANGUAGE JAVASCRIPT
IMMUTABLE
AS $$
    function setup() {
        @@SF_LIBRARY_CONTENT@@
        s2LibGlobal = s2Lib;
    }

    if (typeof(s2LibGlobal) === "undefined") {
        setup();
    }

    return s2LibGlobal.version;
$$;