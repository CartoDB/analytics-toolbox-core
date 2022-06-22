----------------------------
-- Copyright (C) 2022 CARTO
----------------------------

CREATE OR REPLACE FUNCTION QUADBIN_POLYFILL
(geog GEOGRAPHY, resolution INT)
RETURNS ARRAY
AS $$
    IFF(geog IS NULL OR resolution IS NULL,
        NULL,
        IFF(resolution < 0 OR resolution > 29,
            NULL, (
            WITH
            __bbox AS (
                SELECT 
                    ST_XMIN(geog) as xmin,
                    ST_YMIN(geog) as ymin,
                    ST_XMAX(geog) as xmax,
                    ST_YMAX(geog) as ymax
            ),
            __params AS (
                SELECT
                    resolution AS z,
                    xmin AS minlon, ymin AS minlat,
                    xmax AS maxlon, ymax AS maxlat,
                    ACOS(-1) AS PI
                FROM __bbox
            ),
            __tile_coords_range AS (
                SELECT
                    z,
                    CAST(FLOOR(BITSHIFTLEFT(1, z) * ((minlon / 360.0) + 0.5)) AS INT) AS xmin,
                    CAST(FLOOR(BITSHIFTLEFT(1, z) * (0.5 - (LN(TAN(PI/4.0 + maxlat/2.0 * PI/180.0)) / (2*PI)))) AS INT) AS ymin,
                    CAST(FLOOR(BITSHIFTLEFT(1, z) * ((maxlon / 360.0) + 0.5)) AS INT) AS xmax,
                    CAST(FLOOR(BITSHIFTLEFT(1, z) * (0.5 - (LN(TAN(PI/4.0 + minlat/2.0 * PI/180.0)) / (2*PI)))) AS INT) AS ymax
                FROM __params
            ),
            __cells AS (
                SELECT
                    QUADBIN_FROMZXY(z, x.n, y.n) AS quadbin
                FROM __tile_coords_range,
                    TABLE(_GENERATE_RANGE(xmin, xmax)) AS x,
                    TABLE(_GENERATE_RANGE(ymin, ymax)) AS y
            )
            SELECT ARRAY_AGG(quadbin)
            FROM __cells
            WHERE ST_INTERSECTS(
                QUADBIN_BOUNDARY(quadbin),
                geog
            ))
        )
    )
$$;