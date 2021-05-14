----------------------------
-- Copyright (C) 2021 CARTO
----------------------------

CREATE OR REPLACE SECURE FUNCTION @@SF_PREFIX@@h3.COMPACT
(h3Array ARRAY)
RETURNS ARRAY
LANGUAGE JAVASCRIPT
AS $$
    @@SF_LIBRARY_CONTENT@@

    if (H3ARRAY == null) {
        return [];
    }
    
    return lib.compact(H3ARRAY);
$$;