----------------------------
-- Copyright (C) 2021 CARTO
----------------------------

CREATE OR REPLACE SECURE FUNCTION H3_COMPACT
(h3Array ARRAY)
RETURNS ARRAY
LANGUAGE JAVASCRIPT
IMMUTABLE
AS $$
    @@SF_LIBRARY_COMPACT@@

    if (H3ARRAY == null) {
        return [];
    }

    return h3Lib.compact(H3ARRAY);
$$;