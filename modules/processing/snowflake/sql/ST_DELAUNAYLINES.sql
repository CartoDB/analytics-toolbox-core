----------------------------
-- Copyright (C) 2021 CARTO
----------------------------

CREATE OR REPLACE SECURE FUNCTION ST_DELAUNAYLINES
(points ARRAY)
RETURNS ARRAY
AS $$(
    SELECT _DELAUNAYHELPER(points)
)$$;