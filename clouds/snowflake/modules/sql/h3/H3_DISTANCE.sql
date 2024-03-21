----------------------------
-- Copyright (C) 2021 CARTO
----------------------------

CREATE OR REPLACE SECURE FUNCTION @@SF_SCHEMA@@.H3_DISTANCE
(h3_hex_a STRING, h3_hex_b STRING)
RETURNS BIGINT
IMMUTABLE
AS $$
    IFF(
	@@SF_SCHEMA@@.H3_ISVALID(h3_hex_a) AND @@SF_SCHEMA@@.H3_ISVALID(h3_hex_b) AND H3_GET_RESOLUTION(h3_hex_a) = H3_GET_RESOLUTION(h3_hex_b),
        CAST(H3_GRID_DISTANCE(h3_hex_a, h3_hex_b) AS BIGINT),
	NULL
    )
$$;
