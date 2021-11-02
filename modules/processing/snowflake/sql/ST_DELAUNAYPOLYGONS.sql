----------------------------
-- Copyright (C) 2021 CARTO
----------------------------

CREATE OR REPLACE SECURE FUNCTION @@SF_PREFIX@@processing.ST_DELAUNAYPOLYGONS
(points ARRAY)
RETURNS ARRAY
IMMUTABLE
AS $$(
    SELECT ARRAY_AGG(ST_ASGEOJSON(ST_MAKEPOLYGON(TO_GEOGRAPHY(unnested.VALUE)))::STRING)
    FROM LATERAL FLATTEN(input => @@SF_PREFIX@@processing._DELAUNAYHELPER(points)) AS unnested
)$$;