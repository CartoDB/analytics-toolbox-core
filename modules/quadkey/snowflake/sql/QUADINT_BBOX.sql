----------------------------
-- Copyright (C) 2021 CARTO
----------------------------

CREATE OR REPLACE FUNCTION _QUADINT_BBOX
(quadint STRING)
RETURNS ARRAY
LANGUAGE JAVASCRIPT
AS $$
    @@SF_LIBRARY_CONTENT@@
    
    if (!QUADINT) {
        throw new Error('NULL argument passed to UDF');
    }
    return quadkeyLib.bbox(QUADINT);
$$;

CREATE OR REPLACE SECURE FUNCTION QUADINT_BBOX
(quadint BIGINT)
RETURNS ARRAY
AS $$
    _QUADINT_BBOX(CAST(QUADINT AS STRING))
$$;