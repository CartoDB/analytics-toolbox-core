---------------------------------
-- Copyright (C) 2021-2024 CARTO
---------------------------------

CREATE OR REPLACE SECURE FUNCTION @@SF_SCHEMA@@.H3_TOCHILDREN
(h3_hex VARCHAR, resolution INT)
RETURNS ARRAY
IMMUTABLE
AS $$
    IFF(
	@@SF_SCHEMA@@.H3_ISVALID(h3_hex) AND RESOLUTION >= H3_GET_RESOLUTION(h3_hex),
	H3_CELL_TO_CHILDREN_STRING(h3_hex, RESOLUTION),
	[]
    )
$$;
