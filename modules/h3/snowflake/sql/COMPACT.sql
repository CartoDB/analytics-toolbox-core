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

    @@SF_LIBRARY_COMPACT@@

    return h3Lib.compact(H3ARRAY);
$$;