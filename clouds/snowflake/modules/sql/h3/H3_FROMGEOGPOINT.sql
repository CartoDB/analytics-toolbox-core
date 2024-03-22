----------------------------
-- Copyright (C) 2021-2024 CARTO
----------------------------

CREATE OR REPLACE SECURE FUNCTION @@SF_SCHEMA@@.H3_FROMGEOGPOINT
(geog GEOGRAPHY, resolution INT)
RETURNS STRING
IMMUTABLE
AS $$
    IFF(ST_NPOINTS(geog) = 1 AND resolution >= 0 AND resolution <= 15,
	H3_POINT_TO_CELL_STRING(geog, resolution),
        NULL)
$$;
