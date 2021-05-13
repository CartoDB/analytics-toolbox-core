----------------------------
-- Copyright (C) 2021 CARTO
----------------------------

CREATE OR REPLACE FUNCTION @@SF_PREFIX@@quadkey._BBOX
(quadint STRING)
RETURNS ARRAY
LANGUAGE JAVASCRIPT
AS
$$
    @@SF_LIBRARY_CONTENT@@
    
    if(!QUADINT)
    {
        throw new Error('NULL argument passed to UDF');
    }
    return bbox(QUADINT);
$$;

CREATE OR REPLACE SECURE FUNCTION @@SF_PREFIX@@quadkey.BBOX
(quadint BIGINT)
RETURNS ARRAY
AS
$$
    @@SF_PREFIX@@quadkey._BBOX(CAST(QUADINT AS STRING))
$$;