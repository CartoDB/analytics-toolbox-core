----------------------------
-- Copyright (C) 2021 CARTO
----------------------------

CREATE OR REPLACE SECURE FUNCTION ST_VORONOIPOLYGONS
(points ARRAY, bbox ARRAY)
RETURNS ARRAY
AS $$(
    _VORONOIHELPER(points, bbox, 'poly')
)$$;

CREATE OR REPLACE SECURE FUNCTION ST_VORONOIPOLYGONS
(points ARRAY)
RETURNS ARRAY
AS $$(
    _VORONOIHELPER(points, ARRAY_CONSTRUCT(-180,-85,180,85), 'poly')
)$$;