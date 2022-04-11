----------------------------
-- Copyright (C) 2021 CARTO
----------------------------

CREATE OR REPLACE FUNCTION `@@BQ_PREFIX@@carto.QUADINT_CENTER`(quadint INT64)
RETURNS GEOGRAPHY
AS (
    CASE
    -- Deal with level 0 boundary issue.
      WHEN quadint=0 THEN
            ST_GEOGPOINT(0,0)
    -- Deal with level 1. Prevent error from antipodal vertices.
      WHEN quadint=1 THEN
            ST_GEOGPOINT(-90,45)
      WHEN quadint=33 THEN
            ST_GEOGPOINT(90,45)
      WHEN quadint=65 THEN
            ST_GEOGPOINT(-90,-45)
      WHEN quadint=97 THEN
            ST_GEOGPOINT(90,-45)

      ELSE COALESCE(
            ST_GEOGPOINT(
                `@@BQ_PREFIX@@carto.__TILE_TOLONG`(`@@BQ_PREFIX@@carto.QUADINT_TOZXY`(quadint).x*2+1, `@@BQ_PREFIX@@carto.QUADINT_TOZXY`(quadint).z+1),
                `@@BQ_PREFIX@@carto.__TILE_TOLAT`(`@@BQ_PREFIX@@carto.QUADINT_TOZXY`(quadint).y*2+1, `@@BQ_PREFIX@@carto.QUADINT_TOZXY`(quadint).z+1)
            ),
            ERROR('NULL argument passed to UDF')
        )
    END
);