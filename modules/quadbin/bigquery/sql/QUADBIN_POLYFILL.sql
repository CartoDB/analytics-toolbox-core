----------------------------
-- Copyright (C) 2022 CARTO
----------------------------

CREATE OR REPLACE FUNCTION `@@BQ_PREFIX@@carto.QUADBIN_POLYFILL`
(geog GEOGRAPHY, resolution INT64)
RETURNS ARRAY<INT64>
AS ((
    IF(geog IS NULL OR resolution IS NULL,
        NULL,
        IF(resolution < 0 OR resolution > 29,
            ERROR('Invalid resolution, should be between 0 and 29'), (
            WITH
            __bbox AS (
                SELECT ST_BOUNDINGBOX(geog) AS box
            ),
            __params AS (
                SELECT
                    resolution AS z,
                    box.xmin AS minlon, box.ymin AS minlat,
                    box.xmax AS maxlon, box.ymax AS maxlat,
                    ACOS(-1) AS PI
                FROM __bbox
            ),
            __tile_coords_range AS (
                SELECT
                    z,
                    CAST(FLOOR((1 << z) * ((minlon / 360.0) + 0.5)) AS INT64) AS xmin,
                    CAST(FLOOR((1 << z) * (0.5 - (LN(TAN(PI/4.0 + maxlat/2.0 * PI/180.0)) / (2*PI)))) AS INT64) AS ymin,
                    CAST(FLOOR((1 << z) * ((maxlon / 360.0) + 0.5)) AS INT64) AS xmax,
                    CAST(FLOOR((1 << z) * (0.5 - (LN(TAN(PI/4.0 + minlat/2.0 * PI/180.0)) / (2*PI)))) AS INT64) AS ymax
                FROM __params
            ),
            __cells AS (
                SELECT
                    `@@BQ_PREFIX@@carto.QUADBIN_FROMZXY`(z, x, y) AS quadbin
                FROM __tile_coords_range,
                    UNNEST(GENERATE_ARRAY(xmin, xmax)) AS x,
                    UNNEST(GENERATE_ARRAY(ymin, ymax)) AS y
            )
            SELECT ARRAY_AGG(quadbin)
            FROM __cells
            WHERE ST_INTERSECTS(
                `@@BQ_PREFIX@@carto.QUADBIN_BOUNDARY`(quadbin),
                geog
            ))
        )
    )
));