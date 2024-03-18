----------------------------
-- Copyright (C) 2021 CARTO
----------------------------

CREATE OR REPLACE SECURE FUNCTION @@SF_SCHEMA@@.H3_BOUNDARY
(index STRING)
RETURNS GEOGRAPHY
IMMUTABLE
AS $$
    IFF(
	@@SF_SCHEMA@@.H3_ISVALID(INDEX),
        H3_CELL_TO_BOUNDARY(INDEX),
	NULL
    )
$$;
