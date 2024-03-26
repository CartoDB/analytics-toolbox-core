---------------------------------
-- Copyright (C) 2021-2024 CARTO
---------------------------------

CREATE OR REPLACE SECURE FUNCTION @@SF_SCHEMA@@.H3_TOPARENT
(h3_hex STRING, resolution INT)
RETURNS STRING
IMMUTABLE
AS $$
    IFF(
	@@SF_SCHEMA@@.H3_ISVALID(h3_hex) AND RESOLUTION <= H3_GET_RESOLUTION(h3_hex),
	H3_CELL_TO_PARENT(h3_hex, resolution),
	NULL
    )
$$;
