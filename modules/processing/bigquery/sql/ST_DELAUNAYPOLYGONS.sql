----------------------------
-- Copyright (C) 2021 CARTO
----------------------------

CREATE OR REPLACE FUNCTION `@@BQ_PREFIX@@carto.ST_DELAUNAYPOLYGONS`
(points ARRAY<GEOGRAPHY>)
RETURNS ARRAY<GEOGRAPHY>
AS ((
    SELECT ARRAY(
        SELECT ST_MAKEPOLYGON(unnested)
        FROM UNNEST((SELECT `@@BQ_PREFIX@@carto.__DELAUNAYGENERIC`(points))) AS unnested
    )
));