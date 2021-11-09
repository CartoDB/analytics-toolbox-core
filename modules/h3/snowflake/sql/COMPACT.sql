----------------------------
-- Copyright (C) 2021 CARTO
----------------------------

CREATE OR REPLACE SECURE FUNCTION @@SF_PREFIX@@h3.COMPACT
(h3Array ARRAY)
RETURNS ARRAY
LANGUAGE JAVASCRIPT
IMMUTABLE
AS $$
    if (H3ARRAY == null) {
        return [];
    }

    function setup() {
        @@SF_LIBRARY_COMPACT@@
        compact = h3Lib.compact;
    }

    if (typeof(compact) === "undefined") {
        setup();
    }

    return compact(H3ARRAY);
$$;