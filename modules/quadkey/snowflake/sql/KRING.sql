----------------------------
-- Copyright (C) 2021 CARTO
----------------------------

CREATE OR REPLACE FUNCTION @@SF_PREFIX@@quadkey._KRING
(quadint STRING, distance DOUBLE)
RETURNS ARRAY
LANGUAGE JAVASCRIPT
AS $$
    @@SF_LIBRARY_CONTENT@@
    
    if(!QUADINT)
    {
        throw new Error('NULL argument passed to UDF');
    }

    if(DISTANCE == null)
    {
        DISTANCE = 1;
    }
    let neighbors = kring(QUADINT, DISTANCE);
    return neighbors.map(String);
$$;

CREATE OR REPLACE SECURE FUNCTION @@SF_PREFIX@@quadkey.KRING
(quadint BIGINT, distance INT)
RETURNS ARRAY
AS $$
    @@SF_PREFIX@@quadkey._KRING(CAST(QUADINT AS STRING), CAST(DISTANCE AS DOUBLE))
$$;