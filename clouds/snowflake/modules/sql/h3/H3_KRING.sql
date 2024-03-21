----------------------------
-- Copyright (C) 2021 CARTO
----------------------------

CREATE OR REPLACE SECURE FUNCTION @@SF_SCHEMA@@.H3_KRING
(h3_hex STRING, distance INT)
RETURNS ARRAY
IMMUTABLE
AS $$
    CASE
        WHEN distance IS NULL or distance < 0 THEN @@SF_SCHEMA@@._CARTO_ARRAY_ERROR('Invalid input size')
        WHEN NOT @@SF_SCHEMA@@.H3_ISVALID(h3_hex) THEN @@SF_SCHEMA@@._CARTO_ARRAY_ERROR('Invalid input origin')
	ELSE H3_GRID_DISK(h3_hex, distance)
    END
$$;
