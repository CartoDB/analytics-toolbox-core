----------------------------
-- Copyright (C) 2021 CARTO
----------------------------

CREATE OR REPLACE FUNCTION `@@BQ_PREFIX@@processing.ST_DELAUNAYLINES`
(points ARRAY<GEOGRAPHY>)
RETURNS ARRAY<GEOGRAPHY>
AS ((
    SELECT `@@BQ_PREFIX@@processing.__DELAUNAYGENERIC`(points)
));
