----------------------------
-- Copyright (C) 2026 CARTO
----------------------------

-- Converts longitude/latitude/resolution to a quadbin index via
-- Web Mercator projection, then delegates to QUADBIN_FROMZXY.

CREATE OR REPLACE FUNCTION @@DB_SCHEMA@@.QUADBIN_FROMLONGLAT
(longitude DOUBLE, latitude DOUBLE, resolution INT)
RETURNS BIGINT
RETURN (
    IF(
        longitude IS NULL OR latitude IS NULL OR resolution IS NULL,
        NULL,
        IF(
            resolution < 0 OR resolution > 26,
            RAISE_ERROR('Invalid resolution: should be between 0 and 26'),
            (
                WITH
                __params AS (
                    SELECT
                        resolution AS z,
                        longitude,
                        CAST(1 AS BIGINT) << resolution AS num_tiles,
                        ACOS(-1) AS pi,
                        GREATEST(-89.0, LEAST(89.0, latitude)) AS clamped_lat
                ),

                __sinlat AS (
                    SELECT SIN(__params.clamped_lat * __params.pi / 180.0) AS sinlat
                    FROM __params
                ),

                __zxy AS (
                    SELECT
                        __params.z,
                        CAST(FLOOR(__params.num_tiles * ((__params.longitude / 360.0) + 0.5)) AS INT)
                        & CAST(__params.num_tiles - 1 AS INT) AS x,
                        CAST(
                            FLOOR(
                                GREATEST(0, LEAST(
                                    __params.num_tiles - 1,
                                    __params.num_tiles * (
                                        0.5 - 0.25
                                        * LN((1 + __sinlat.sinlat) / (1 - __sinlat.sinlat))
                                        / __params.pi
                                    )
                                ))
                            ) AS INT
                        ) AS y
                    FROM __params, __sinlat
                )

                SELECT @@DB_SCHEMA@@.QUADBIN_FROMZXY(z, x, y)
                FROM __zxy
            )
        )
    )
);
