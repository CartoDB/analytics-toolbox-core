----------------------------
-- Copyright (C) 2021 CARTO
----------------------------

CREATE OR REPLACE SECURE FUNCTION @@SF_SCHEMA@@.H3_TOPARENT
(index STRING, resolution INT)
RETURNS STRING
IMMUTABLE
AS $$
    IFF(
	@@SF_SCHEMA@@.H3_ISVALID(INDEX),
	H3_CELL_TO_PARENT(INDEX, RESOLUTION),
	NULL
    )
$$;
