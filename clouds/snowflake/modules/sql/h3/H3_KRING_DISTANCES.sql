----------------------------
-- Copyright (C) 2021 CARTO
----------------------------

CREATE OR REPLACE SECURE FUNCTION @@SF_SCHEMA@@._H3_KRING_DISTANCES
(ORIGIN STRING, SIZE INT)
RETURNS ARRAY
AS $$
    SELECT ARRAY_AGG(OBJECT_CONSTRUCT('index', h3_key, 'distance', distance)) AS res
        FROM
        (SELECT value AS h3_key,
        H3_GRID_DISTANCE(ORIGIN, h3_key) AS distance
        FROM LATERAL FLATTEN(INPUT => H3_GRID_DISK(ORIGIN, SIZE))) AS x
$$;

CREATE OR REPLACE SECURE FUNCTION @@SF_SCHEMA@@.H3_KRING_DISTANCES
(origin STRING, size INT)
RETURNS ARRAY
IMMUTABLE
AS $$
    CASE
        WHEN SIZE IS NULL or SIZE < 0 THEN @@SF_SCHEMA@@._CARTO_ARRAY_ERROR('Invalid input size')
        WHEN NOT @@SF_SCHEMA@@.H3_ISVALID(ORIGIN) THEN @@SF_SCHEMA@@._CARTO_ARRAY_ERROR('Invalid input origin')
	ELSE @@SF_SCHEMA@@._H3_KRING_DISTANCES(ORIGIN, SIZE)
    END
$$;
