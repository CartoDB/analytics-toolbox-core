----------------------------
-- Copyright (C) 2021 CARTO
----------------------------

CREATE OR REPLACE FUNCTION `@@BQ_DATASET@@.ST_DELAUNAYPOLYGONS`
(points ARRAY<GEOGRAPHY>)
RETURNS ARRAY<GEOGRAPHY>
AS ((
    SELECT ARRAY(
        SELECT ST_MAKEPOLYGON(unnested)
        FROM
            UNNEST(
                (
                    SELECT `@@BQ_DATASET@@.__DELAUNAYGENERIC`(
                            points
                        )
                )
            ) AS unnested
    )
));
