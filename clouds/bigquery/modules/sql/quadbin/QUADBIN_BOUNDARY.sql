----------------------------
-- Copyright (C) 2022 CARTO
----------------------------

CREATE OR REPLACE FUNCTION `@@BQ_DATASET@@.QUADBIN_BOUNDARY`(
    quadbin INT64
)
RETURNS GEOGRAPHY
AS (
    CASE quadbin
        WHEN NULL THEN
            NULL
        -- Deal with level 0 boundary issue.
        WHEN 5192650370358181887 THEN
            ST_GEOGFROMGEOJSON(
                '{"coordinates":[[[-180,85.0511287798066],[-180,-85.0511287798066],[180,-85.0511287798066],[180,85.0511287798066],[-180,85.0511287798066]]],"type":"Polygon"}'
            )
        -- Deal with level 1. Prevent error from antipodal vertices.
        WHEN 5193776270265024511 THEN -- Z=1 X=0 Y=0
            ST_GEOGFROMTEXT(
                'POLYGON((0 0, 0 85.0511287798066, -180 85.0511287798066, -180 0, -90 0, 0 0))'
            )
        WHEN 5194902170171867135 THEN -- Z=1 X=1 Y=0
            ST_GEOGFROMTEXT(
                'POLYGON((180 0, 180 85.0511287798066, 0 85.0511287798066, 0 0, 90 0, 180 0))'
            )
        WHEN 5196028070078709759 THEN -- Z=1 X=0 Y=1
            ST_GEOGFROMTEXT(
                'POLYGON((0 0, -90 0, 180 0, -180 -85.0511287798066, 0 -85.0511287798066, 0 0))'
            )
        WHEN 5197153969985552383 THEN -- Z=1 X=1 Y=1
            ST_GEOGFROMTEXT(
                'POLYGON((180 0, 90 0, 0 0, 0 -85.0511287798066, 180 -85.0511287798066, 180 0))'
            )
        ELSE (
            WITH
            __bbox AS (
                SELECT `@@BQ_DATASET@@.QUADBIN_BBOX`(
                        quadbin
                    ) AS b
            )

            SELECT ST_MAKEPOLYGON(
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
