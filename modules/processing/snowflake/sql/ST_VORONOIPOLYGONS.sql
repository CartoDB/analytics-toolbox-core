----------------------------
-- Copyright (C) 2021 CARTO
----------------------------

CREATE OR REPLACE SECURE FUNCTION @@SF_PREFIX@@processing.ST_VORONOIPOLYGONS
(points ARRAY, bbox ARRAY)
RETURNS ARRAY
IMMUTABLE
AS $$(
    @@SF_PREFIX@@processing._VORONOIHELPER(points, bbox, 'poly')
)$$;

CREATE OR REPLACE SECURE FUNCTION @@SF_PREFIX@@processing.ST_VORONOIPOLYGONS
(points ARRAY)
RETURNS ARRAY
IMMUTABLE
AS $$(
    @@SF_PREFIX@@processing._VORONOIHELPER(points, ARRAY_CONSTRUCT(-180,-85,180,85), 'poly')
)$$;