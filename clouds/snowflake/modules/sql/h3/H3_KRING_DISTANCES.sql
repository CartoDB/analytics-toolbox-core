----------------------------
-- Copyright (C) 2021-2024 CARTO
----------------------------

CREATE OR REPLACE SECURE FUNCTION @@SF_SCHEMA@@._H3_KRING_DISTANCES
(origin STRING, hexarray ARRAY)
RETURNS ARRAY
LANGUAGE JAVASCRIPT
AS $$
    @@SF_LIBRARY_H3_DISTANCE@@
    var results = []
    HEXARRAY.forEach(hex => results.push({"index": hex, "distance": h3DistanceLib.h3Distance(ORIGIN, hex)}))
    return results
$$;

CREATE OR REPLACE SECURE FUNCTION @@SF_SCHEMA@@.H3_KRING_DISTANCES
(origin STRING, size INT)
RETURNS ARRAY
IMMUTABLE
AS $$
    CASE
        WHEN SIZE IS NULL or SIZE < 0 THEN @@SF_SCHEMA@@._CARTO_ARRAY_ERROR('Invalid input size')
        WHEN NOT @@SF_SCHEMA@@.H3_ISVALID(ORIGIN) THEN @@SF_SCHEMA@@._CARTO_ARRAY_ERROR('Invalid input origin')
	ELSE @@SF_SCHEMA@@._H3_KRING_DISTANCES(origin, H3_GRID_DISK(ORIGIN, SIZE))
    END
$$;
