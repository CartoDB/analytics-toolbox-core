----------------------------
-- Copyright (C) 2021 CARTO
----------------------------

CREATE OR REPLACE SECURE FUNCTION @@SF_PREFIX@@processing.ST_VORONOILINES
(points ARRAY, bbox ARRAY)
RETURNS ARRAY
AS $$(
    @@SF_PREFIX@@processing._VORONOIHELPER(points, bbox, 'lines')
)$$;

CREATE OR REPLACE SECURE FUNCTION @@SF_PREFIX@@processing.ST_VORONOILINES
(points ARRAY)
RETURNS ARRAY
AS $$(
    @@SF_PREFIX@@processing._VORONOIHELPER(points, null, 'lines')
)$$;