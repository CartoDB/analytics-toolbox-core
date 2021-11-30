----------------------------
-- Copyright (C) 2021 CARTO
----------------------------

CREATE OR REPLACE FUNCTION `@@BQ_PREFIX@@carto.ST_DELAUNAYLINES`
(points ARRAY<GEOGRAPHY>)
RETURNS ARRAY<GEOGRAPHY>
AS ((
    SELECT `@@BQ_PREFIX@@carto.__DELAUNAYGENERIC`(points)
));