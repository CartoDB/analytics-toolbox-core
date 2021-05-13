----------------------------
-- Copyright (C) 2021 CARTO
----------------------------

CREATE OR REPLACE FUNCTION @@SF_PREFIX@@quadkey._TOPARENT
(quadint STRING, resolution DOUBLE)
RETURNS STRING
LANGUAGE JAVASCRIPT
AS $$
    @@SF_LIBRARY_CONTENT@@

    if(!QUADINT || RESOLUTION == null)
    {
        throw new Error('NULL argument passed to UDF');
    }
    return toParent(QUADINT, RESOLUTION).toString(); 
$$;

CREATE OR REPLACE SECURE FUNCTION @@SF_PREFIX@@quadkey.TOPARENT
(quadint BIGINT, resolution INT)
RETURNS BIGINT
AS $$
    CAST(@@SF_PREFIX@@quadkey._TOPARENT(CAST(QUADINT AS STRING), CAST(RESOLUTION AS DOUBLE)) AS BIGINT)
$$;