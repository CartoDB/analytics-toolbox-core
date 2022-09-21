----------------------------
-- Copyright (C) 2021 CARTO
----------------------------

CREATE OR REPLACE FUNCTION `@@BQ_DATASET@@.ST_POLYGONIZE`
(lines ARRAY<GEOGRAPHY>)
RETURNS ARRAY<GEOGRAPHY>
AS ((
    SELECT ARRAY(SELECT ST_MAKEPOLYGON(line) FROM UNNEST(lines) AS line)
));
