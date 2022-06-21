
----------------------------
-- Copyright (C) 2022 CARTO
----------------------------

CREATE OR REPLACE FUNCTION `@@BQ_PREFIX@@carto.QUADBIN_FROMLONGLAT`
(longitude FLOAT64, latitude FLOAT64, resolution INT64)
RETURNS INT64
AS ((
    IF(longitude IS NULL OR latitude IS NULL OR resolution IS NULL,
        NULL,
        IF (resolution < 0 OR resolution > 29,
            ERROR('Invalid resolution; should be between 0 and 29'), (
            WITH
            __params AS (
                SELECT
                    resolution AS z,
                    ACOS(-1) AS PI,
                    GREATEST(-85.05, LEAST(85.05, latitude)) AS latitude
            ),
            __zxy AS (
                SELECT
                    z,
                    CAST(FLOOR((1 << z) * ((longitude / 360.0) + 0.5)) AS INT64) & ((1 << z) - 1) AS x,
                    CAST(FLOOR((1 << z) * (0.5 - (LN(TAN(PI/4.0 + latitude/2.0 * PI/180.0)) / (2*PI)))) AS INT64) & ((1 << z) - 1) AS y
                FROM __params
            )
            SELECT `@@BQ_PREFIX@@carto.QUADBIN_FROMZXY`(z, x, y),
            FROM __zxy)
        )
    )
));