----------------------------
-- Copyright (C) 2021 CARTO
----------------------------


CREATE OR REPLACE SECURE FUNCTION @@SF_SCHEMA@@.H3_KRING
(origin STRING, size INT)
RETURNS ARRAY
IMMUTABLE
AS $$
    CASE
        WHEN SIZE IS NULL or SIZE < 0 THEN @@SF_SCHEMA@@._CARTO_ARRAY_ERROR('Invalid input size')
        WHEN NOT @@SF_SCHEMA@@.H3_ISVALID(ORIGIN) THEN @@SF_SCHEMA@@._CARTO_ARRAY_ERROR('Invalid input origin')
	ELSE H3_GRID_DISK(ORIGIN, SIZE)
    END
$$;
