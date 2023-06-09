----------------------------
-- Copyright (C) 2022 CARTO
----------------------------

CREATE OR REPLACE FUNCTION `@@BQ_DATASET@@.QUADBIN_POLYFILL`
(geog GEOGRAPHY, resolution INT64)
RETURNS ARRAY<INT64>
AS ((
    IF(geog IS NULL OR resolution IS NULL,
        NULL,
        IF(resolution < 0 OR resolution > 26,
            ERROR('Invalid resolution, should be between 0 and 26'), (
            WITH
            __bbox AS (
                SELECT ST_BOUNDINGBOX(geog) AS box
            ),

            __params AS (
                SELECT
                    resolution AS z,
                    box.xmin AS minlon,
                    box.ymin AS minlat,
                    box.xmax AS maxlon,
                    box.ymax AS maxlat,
                    (1 << resolution) AS z2,
                    ACOS(-1) AS pi
                FROM __bbox
            ),

            __sinlat AS (
                SELECT
                    SIN(minlat * pi / 180.0) AS sinlat_min,
                    SIN(maxlat * pi / 180.0) AS sinlat_max
                FROM __params
            ),

            __xs AS (
                -- precalculate Xs to allow simple use of
                -- CASE in the next CTE
                SELECT
                    CAST(
                            FLOOR(z2 * ((minlon / 360.0) + 0.5)) AS INT64
                        ) & (z2 - 1)   -- bitwise way to calc MODULO
                    AS xmin,
                    CAST(
                            FLOOR(z2 * ((maxlon / 360.0) + 0.5)) AS INT64
                        ) & (z2 - 1)   -- bitwise way to calc MODULO
                    AS xmax
                FROM
                    __params
            ),

            __tile_coords_range AS (
                SELECT
                    z,

                    CASE
                        WHEN xmin < 0 THEN xmin + z2
                        ELSE xmin
                    END
                    AS xmin,

                    CAST(
                        -- floor before cast to avoid up rounding to the next tiLe
                        FLOOR(
                            z2 * (
                                0.5 - 0.25 * LN(
                                    (1 + sinlat_max) / (1 - sinlat_max)
                                ) / pi
                            )
                        ) AS INT64
                    )
                    AS ymin,

                    CASE
                        WHEN xmax < 0 THEN xmax + z2
                        ELSE xmax
                    END
                    AS xmax,

                    CAST(
                        -- floor before cast to avoid up rounding to the next tiLe
                        FLOOR(
                            z2 * (
                                0.5 - 0.25 * LN(
                                    (1 + sinlat_min) / (1 - sinlat_min)
                                ) / pi
                            )
                        ) AS INT64
                    )
                    AS ymax

                FROM __params, __xs, __sinlat
            ),

            __cells AS (
                SELECT `@@BQ_DATASET@@.QUADBIN_FROMZXY`(z, x, y) AS quadbin
                FROM __tile_coords_range,
                    UNNEST(GENERATE_ARRAY(xmin, xmax)) AS x,
                    UNNEST(GENERATE_ARRAY(ymin, ymax)) AS y
            )

            SELECT ARRAY_AGG(quadbin)
            FROM __cells
            WHERE ST_INTERSECTS(
                `@@BQ_DATASET@@.QUADBIN_BOUNDARY`(
                    quadbin
                ),
                geog
            )
        ))
    )
));
