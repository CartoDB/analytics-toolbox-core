----------------------------
-- Copyright (C) 2022 CARTO
----------------------------

CREATE OR REPLACE FUNCTION @@PG_SCHEMA@@.QUADBIN_POLYFILL(
    geom GEOMETRY,
    resolution INT
)
RETURNS BIGINT[]
AS
$BODY$
  SELECT CASE
    WHEN resolution < 0 OR resolution > 26 THEN @@PG_SCHEMA@@.__CARTO_ERROR(FORMAT('Invalid resolution "%s"; should be between 0 and 26', resolution))::BIGINT[]
    WHEN resolution IS NULL OR geom IS NULL THEN NULL::BIGINT[]
    ELSE (
        with
        __geom4326 AS (
            select
                CASE ST_SRID(geom)
                    WHEN 0 THEN ST_SETSRID(geom, 4326)
                    ELSE ST_TRANSFORM(geom, 4326)
                END AS geom4326
        ),
        __bbox AS (
            SELECT geom4326, BOX2D(geom4326) AS b FROM __geom4326
        ),
        __params AS (
            SELECT
                geom4326,
                resolution AS z,
                (1 << resolution) AS z2,
                ST_XMIN(b) AS minlon,
                ST_YMIN(b) AS minlat,
                ST_XMAX(b) AS maxlon,
                ST_YMAX(b) AS maxlat
            FROM __bbox
        ),
        __sinlat AS (
            SELECT
                SIN(minlat * PI() / 180.0) as sinlat_min,
                SIN(maxlat * PI() / 180.0) as sinlat_max
            FROM __params
        ),
        __Xs AS (
            SELECT
                (FLOOR(z2 * ((minlon / 360.0) + 0.5)))::BIGINT & (z2 - 1) AS xmin,
                (FLOOR(z2 * ((maxlon / 360.0) + 0.5)))::BIGINT & (z2 - 1) AS xmax
            FROM __params
        ),
        __tile_coords_range AS (
            SELECT
                geom4326,
                z,
                (CASE
                    WHEN xmin < 0 THEN xmin + z2
                    ELSE xmin
                end)::INT AS xmin,
                (FLOOR(z2 * (0.5 - 0.25 * (LN((1 + sinlat_max)/(1 - sinlat_max)) / PI()))))::INT AS ymin,
                (CASE
                    WHEN xmax < 0 THEN xmax + z2
                    ELSE xmax
                end)::INT AS xmax,
                (FLOOR(z2 * (0.5 - 0.25 * (LN((1 + sinlat_min)/(1 - sinlat_min)) / PI()))))::INT AS ymax
            FROM __params, __Xs, __sinlat
        ),
        __cells AS (
            SELECT
                geom4326,
                @@PG_SCHEMA@@.QUADBIN_FROMZXY(z, x, y) AS quadbin
            FROM __tile_coords_range,
                generate_series(xmin, xmax) AS x,
                generate_series(ymin, ymax) AS y
        )
        SELECT ARRAY_AGG(quadbin)
        FROM __cells
        WHERE ST_INTERSECTS(
            @@PG_SCHEMA@@.QUADBIN_BOUNDARY(quadbin),
            geom4326
        )
    )
    END;
$BODY$
LANGUAGE sql IMMUTABLE PARALLEL SAFE;
