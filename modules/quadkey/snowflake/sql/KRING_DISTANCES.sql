----------------------------
-- Copyright (C) 2021 CARTO
----------------------------

CREATE OR REPLACE FUNCTION @@SF_PREFIX@@quadkey._KRING_DISTANCES
(origin STRING, size DOUBLE)
RETURNS ARRAY
LANGUAGE JAVASCRIPT
AS $$
    @@SF_LIBRARY_CONTENT@@
    
    if (!ORIGIN || SIZE == null || SIZE < 0) {
        return null;
    }

    return quadkeyLib.kRingDistances(ORIGIN, parseInt(SIZE));
$$;

CREATE OR REPLACE SECURE FUNCTION @@SF_PREFIX@@quadkey.KRING_DISTANCES
(origin BIGINT, size INT)
RETURNS ARRAY
AS $$
    @@SF_PREFIX@@quadkey._KRING_DISTANCES(CAST(ORIGIN AS STRING), CAST(SIZE AS DOUBLE))
$$;