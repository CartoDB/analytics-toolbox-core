----------------------------
-- Copyright (C) 2021 CARTO
----------------------------

CREATE OR REPLACE FUNCTION `@@BQ_PREFIX@@quadkey.ST_BOUNDARY`(quadint INT64)
RETURNS GEOGRAPHY
AS (
    CASE
    -- Deal with level 0 boundary issue.
      WHEN quadint=0 THEN ST_GeogFromText('FULLGLOBE')
    -- Deal with level 1. Prevent error from antipodal vertices.
      WHEN quadint=1 THEN ST_GeogFromText('POLYGON((0 0,0 90,-180 90,-180 0,-90 0,0 0))')
      WHEN quadint=33 THEN ST_GeogFromText('POLYGON((180 0,180 90,0 90,0 0,90 0,180 0))')
      WHEN quadint=65 THEN ST_GeogFromText('POLYGON((0 0,-90 0,-180 0,-180 -90,0 -90,0 0))')
      WHEN quadint=97 THEN ST_GeogFromText('POLYGON((180 0,90 0,0 0,0 -90,180 -90,180 0))')
      ELSE COALESCE(
            SAFE.ST_MAKEPOLYGON(
                ST_MAKELINE([
                    ST_GEOGPOINT(
                        `@@BQ_PREFIX@@quadkey.__BBOX_E`(quadint),
                        `@@BQ_PREFIX@@quadkey.__BBOX_N`(quadint)),
                    ST_GEOGPOINT(
                        `@@BQ_PREFIX@@quadkey.__BBOX_E`(quadint),
                        `@@BQ_PREFIX@@quadkey.__BBOX_S`(quadint)),
                    ST_GEOGPOINT(
                        `@@BQ_PREFIX@@quadkey.__BBOX_W`(quadint),
                        `@@BQ_PREFIX@@quadkey.__BBOX_S`(quadint)),
                    ST_GEOGPOINT(
                        `@@BQ_PREFIX@@quadkey.__BBOX_W`(quadint),
                        `@@BQ_PREFIX@@quadkey.__BBOX_N`(quadint)),
                    ST_GEOGPOINT(
                        `@@BQ_PREFIX@@quadkey.__BBOX_E`(quadint),
                        `@@BQ_PREFIX@@quadkey.__BBOX_N`(quadint))
                    ])
                ),
            NULL
        )
    END
);