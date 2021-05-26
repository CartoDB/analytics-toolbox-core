----------------------------
-- Copyright (C) 2021 CARTO
----------------------------

CREATE OR REPLACE SECURE FUNCTION @@SF_PREFIX@@processing.ST_DELAUNAYLINES
(points ARRAY)
RETURNS ARRAY
AS $$(
    SELECT @@SF_PREFIX@@processing._DELAUNAYHELPER(points)
)$$;