----------------------------
-- Copyright (C) 2021 CARTO
----------------------------

CREATE OR REPLACE SECURE FUNCTION @@SF_PREFIX@@accessors.VERSION
()
RETURNS STRING
LANGUAGE JAVASCRIPT
IMMUTABLE
AS $$
    function setup() {
        @@SF_LIBRARY_CONTENT@@
        accessorsLibGlobal = accessorsLib;
    }

    if (typeof(accessorsLibGlobal) === "undefined") {
        setup();
    }

    return accessorsLibGlobal.version;
$$;