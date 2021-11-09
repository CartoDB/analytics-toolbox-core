----------------------------
-- Copyright (C) 2021 CARTO
----------------------------

CREATE OR REPLACE SECURE FUNCTION @@SF_PREFIX@@transformations.VERSION
()
RETURNS STRING
LANGUAGE JAVASCRIPT
AS $$
    function setup() {
        @@SF_LIBRARY_CONTENT@@
        transformationsLibGlobal = transformationsLib;
    }

    if (typeof(transformationsLibGlobal) === "undefined") {
        setup();
    }

    return transformationsLibGlobal.version;
$$;