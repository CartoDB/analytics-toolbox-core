----------------------------
-- Copyright (C) 2021 CARTO
----------------------------

CREATE OR REPLACE SECURE FUNCTION @@SF_PREFIX@@processing.ST_VORONOIPOLYGONS
(points ARRAY, bbox ARRAY)
RETURNS ARRAY
AS $$(
    @@SF_PREFIX@@processing._VORONOIHELPER(points, bbox, 'poly')
)$$;

CREATE OR REPLACE SECURE FUNCTION @@SF_PREFIX@@processing.ST_VORONOIPOLYGONS
(points ARRAY)
RETURNS ARRAY
AS $$(
    @@SF_PREFIX@@processing._VORONOIHELPER(points, null, 'poly')
)$$;