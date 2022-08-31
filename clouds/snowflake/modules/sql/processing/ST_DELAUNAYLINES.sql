----------------------------
-- Copyright (C) 2021 CARTO
----------------------------

CREATE OR REPLACE SECURE FUNCTION @@SF_SCHEMA@@.ST_DELAUNAYLINES
(points ARRAY)
RETURNS ARRAY
IMMUTABLE
AS $$(
    SELECT @@SF_SCHEMA@@._DELAUNAYHELPER(points)
)$$;