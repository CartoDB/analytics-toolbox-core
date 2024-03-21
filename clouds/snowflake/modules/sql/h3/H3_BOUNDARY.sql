----------------------------
-- Copyright (C) 2021 CARTO
----------------------------

CREATE OR REPLACE SECURE FUNCTION @@SF_SCHEMA@@.H3_BOUNDARY
(h3_hex STRING)
RETURNS GEOGRAPHY
IMMUTABLE
AS $$
    IFF(
	@@SF_SCHEMA@@.H3_ISVALID(h3_hex),
        H3_CELL_TO_BOUNDARY(h3_hex),
	NULL
    )
$$;
