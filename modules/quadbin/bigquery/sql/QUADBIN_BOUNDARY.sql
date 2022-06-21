----------------------------
-- Copyright (C) 2022 CARTO
----------------------------

CREATE OR REPLACE FUNCTION `@@BQ_PREFIX@@carto.QUADBIN_BOUNDARY`(quadbin INT64)
RETURNS GEOGRAPHY
AS (
    CASE
        WHEN quadbin IS NULL THEN
            NULL
        -- Deal with level 0 boundary issue.
        WHEN quadbin=5188146770730811392 THEN
            ST_GEOGFROMGEOJSON('{"coordinates":[[[-180,85.0511287798066],[-180,-85.0511287798066],[180,-85.0511287798066],[180,85.0511287798066],[-180,85.0511287798066]]],"type":"Polygon"}')
        -- Deal with level 1. Prevent error from antipodal vertices.
        WHEN quadbin=5192650370358181888 THEN
            ST_GEOGFROMTEXT ("POLYGON((0 0, 0 85.0511287798066, -180 85.0511287798066, -180 0, -90 0, 0 0))")
        WHEN quadbin=5193776270265024512 THEN
            ST_GEOGFROMTEXT ("POLYGON((180 0, 180 85.0511287798066, 0 85.0511287798066, 0 0, 90 0, 180 0))")
        WHEN quadbin=5194902170171867136 THEN
            ST_GEOGFROMTEXT ("POLYGON((0 0, -90 0, 180 0, -180 -85.0511287798066, 0 -85.0511287798066, 0 0))")
        WHEN quadbin=5196028070078709760 THEN
            ST_GEOGFROMTEXT ("POLYGON((180 0, 90 0, 0 0, 0 -85.0511287798066, 180 -85.0511287798066, 180 0))")
        ELSE (
            WITH
            __bbox AS (
                SELECT
                    `@@BQ_PREFIX@@carto.QUADBIN_BBOX`(quadbin) AS b
            )
            SELECT
                ST_MAKEPOLYGON(
                    ST_MAKELINE([
                        ST_GEOGPOINT(b[OFFSET(0)], b[OFFSET(3)]),
                        ST_GEOGPOINT(b[OFFSET(0)], b[OFFSET(1)]),
                        ST_GEOGPOINT(b[OFFSET(2)], b[OFFSET(1)]),
                        ST_GEOGPOINT(b[OFFSET(2)], b[OFFSET(3)]),
                        ST_GEOGPOINT(b[OFFSET(0)], b[OFFSET(3)])
                    ])
                )
            FROM __bbox
        )
    END
);