---------------------------------
-- Copyright (C) 2022-2024 CARTO
---------------------------------

CREATE OR REPLACE FUNCTION `@@BQ_DATASET@@.__QUADBIN_POLYFILL_INIT`
(geog GEOGRAPHY, resolution INT64)
RETURNS ARRAY<INT64>
AS ((
    WITH __bbox AS (
        SELECT ST_BOUNDINGBOX(geog) AS box
    ),
    __params AS (
        SELECT
            box.xmin AS minlon,
            box.xmax AS maxlon,
            GREATEST(-89, LEAST(89, box.ymin)) AS minlat,
            GREATEST(-89, LEAST(89, box.ymax)) AS maxlat,
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
    __tile_coords_range AS (
        SELECT
            resolution AS z,
            CAST(
                FLOOR(z2 * ((minlon / 360.0) + 0.5)) AS INT64
            ) AS xmin,
            CAST(
                FLOOR(
                    GREATEST(0, LEAST(z2 - 1,
                        z2 * (
                            0.5 - 0.25 * LN(
                                (1 + sinlat_max) / (1 - sinlat_max)
                            ) / pi
                        )
                    ))
                ) AS INT64
            ) AS ymin,
            CAST(
                FLOOR(z2 * ((maxlon / 360.0) + 0.5)) AS INT64
            ) AS xmax,
            CAST(
                FLOOR(
                    GREATEST(0, LEAST(z2 - 1,
                        z2 * (
                            0.5 - 0.25 * LN(
                                (1 + sinlat_min) / (1 - sinlat_min)
                            ) / pi
                        )
                    ))
                ) AS INT64
            ) AS ymax
        FROM __params, __sinlat
    ),
    -- compute all the quadbin cells contained in the bounding box
    __cells AS (
        SELECT `@@BQ_DATASET@@.QUADBIN_FROMZXY`(z, x, y) AS quadbin
        FROM __tile_coords_range,
            UNNEST(GENERATE_ARRAY(xmin, xmax)) AS x,
            UNNEST(GENERATE_ARRAY(ymin, ymax)) AS y
    )
    SELECT ARRAY_AGG(quadbin)
    FROM __cells
    WHERE ST_INTERSECTS(geog, `@@BQ_DATASET@@.QUADBIN_BOUNDARY`(quadbin))
));

CREATE OR REPLACE FUNCTION `@@BQ_DATASET@@.__GEOG_RESOLUTION`
(geog GEOGRAPHY, resolution INT64)
RETURNS INT64
AS ((
    WITH __geog_area AS (
        SELECT
            ST_AREA(geog) AS geog_area,
            COS(ST_Y(ST_CENTROID(geog)) * ACOS(-1) / 180) AS cos_geog_lat,
            508164597540055.75 AS q0_area
    )
    -- compute the resolution of cells that match the geog area
    SELECT IF(geog_area > 0 AND cos_geog_lat > 0,
        CAST(-LOG(geog_area / q0_area / cos_geog_lat, 4) AS INT64), resolution)
    FROM __geog_area
));

CREATE OR REPLACE FUNCTION `@@BQ_DATASET@@.__QUADBIN_POLYFILL_INTERSECTS`
(geog GEOGRAPHY, use_contains BOOLEAN, init_resolution INT64, resolution INT64)
RETURNS ARRAY<INT64>
AS ((
    WITH __parents AS (
        SELECT parent, COALESCE(ST_CONTAINS(
            geog, IF(use_contains, `@@BQ_DATASET@@.QUADBIN_BOUNDARY`(parent), NULL)
        ), FALSE) AS inside
        FROM UNNEST(`@@BQ_DATASET@@.__QUADBIN_POLYFILL_INIT`(geog, init_resolution)) AS parent
    ),
    __children AS (
        SELECT child, inside
        FROM __parents,
            UNNEST(`@@BQ_DATASET@@.QUADBIN_TOCHILDREN`(parent, resolution)) AS child
    ),
    __children_inside AS (
        SELECT child
        FROM __children
        WHERE inside
    ),
    __children_border AS (
        SELECT child
        FROM __children
        WHERE NOT inside
    ),
    __cells AS (
        SELECT child
        FROM __children_inside
        UNION ALL
        SELECT child
        FROM __children_border
        WHERE ST_INTERSECTS(geog, `@@BQ_DATASET@@.QUADBIN_BOUNDARY`(child))
    )
    SELECT ARRAY_AGG(child)
    FROM __cells
));

CREATE OR REPLACE FUNCTION `@@BQ_DATASET@@.__QUADBIN_POLYFILL_CONTAINS`
(geog GEOGRAPHY, use_contains BOOLEAN, init_resolution INT64, resolution INT64)
RETURNS ARRAY<INT64>
AS ((
    WITH __parents AS (
        SELECT parent, COALESCE(ST_CONTAINS(
            geog, IF(use_contains, `@@BQ_DATASET@@.QUADBIN_BOUNDARY`(parent), NULL)
        ), FALSE) AS inside
        FROM UNNEST(`@@BQ_DATASET@@.__QUADBIN_POLYFILL_INIT`(geog, init_resolution)) AS parent
    ),
    __children AS (
        SELECT child, inside
        FROM __parents,
            UNNEST(`@@BQ_DATASET@@.QUADBIN_TOCHILDREN`(parent, resolution)) AS child
    ),
    __children_inside AS (
        SELECT child
        FROM __children
        WHERE inside
    ),
    __children_border AS (
        SELECT child
        FROM __children
        WHERE NOT inside
    ),
    __cells AS (
        SELECT child
        FROM __children_inside
        UNION ALL
        SELECT child
        FROM __children_border
        WHERE ST_CONTAINS(geog, `@@BQ_DATASET@@.QUADBIN_BOUNDARY`(child))
    )
    SELECT ARRAY_AGG(child)
    FROM __cells
));

CREATE OR REPLACE FUNCTION `@@BQ_DATASET@@.__QUADBIN_POLYFILL_CENTER`
(geog GEOGRAPHY, use_contains BOOLEAN, init_resolution INT64, resolution INT64)
RETURNS ARRAY<INT64>
AS ((
    WITH __parents AS (
        SELECT parent, COALESCE(ST_CONTAINS(
            geog, IF(use_contains, `@@BQ_DATASET@@.QUADBIN_BOUNDARY`(parent), NULL)
        ), FALSE) AS inside
        FROM UNNEST(`@@BQ_DATASET@@.__QUADBIN_POLYFILL_INIT`(geog, init_resolution)) AS parent
    ),
    __children AS (
        SELECT child, inside
        FROM __parents,
            UNNEST(`@@BQ_DATASET@@.QUADBIN_TOCHILDREN`(parent, resolution)) AS child
    ),
    __children_inside AS (
        SELECT child
        FROM __children
        WHERE inside
    ),
    __children_border AS (
        SELECT child
        FROM __children
        WHERE NOT inside
    ),
    __cells AS (
        SELECT child
        FROM __children_inside
        UNION ALL
        SELECT child
        FROM __children_border
        WHERE ST_CONTAINS(geog, `@@BQ_DATASET@@.QUADBIN_CENTER`(child))
    )
    SELECT ARRAY_AGG(child)
    FROM __cells
));

CREATE OR REPLACE FUNCTION `@@BQ_DATASET@@.QUADBIN_POLYFILL_MODE`
(geog GEOGRAPHY, resolution INT64, mode STRING)
RETURNS ARRAY<INT64>
AS ((
    IF(resolution IS NULL OR resolution < 0 OR resolution > 26,
        ERROR('Invalid resolution, should be between 0 and 26'),
        (
            WITH __geog_params AS (
                SELECT
                    `@@BQ_DATASET@@.__GEOG_RESOLUTION`(geog, resolution) AS geog_resolution
            ),
            __params AS (
                SELECT
                    resolution - geog_resolution >= 10 AS use_contains,
                    LEAST(resolution, CAST((resolution + geog_resolution) / 2 AS INT64)) AS init_resolution
                FROM __geog_params
            )
            SELECT CASE mode
            WHEN 'intersects' THEN `@@BQ_DATASET@@.__QUADBIN_POLYFILL_INTERSECTS`(
                geog, use_contains, init_resolution, resolution)
            WHEN 'contains' THEN `@@BQ_DATASET@@.__QUADBIN_POLYFILL_CONTAINS`(
                geog, use_contains, init_resolution, resolution)
            WHEN 'center' THEN `@@BQ_DATASET@@.__QUADBIN_POLYFILL_CENTER`(
                geog, use_contains, init_resolution, resolution)
            END
            FROM __params
        )
    )
));

CREATE OR REPLACE FUNCTION `@@BQ_DATASET@@.QUADBIN_POLYFILL`
(geog GEOGRAPHY, resolution INT64)
RETURNS ARRAY<INT64>
AS ((
    `@@BQ_DATASET@@.QUADBIN_POLYFILL_MODE`(geog, resolution, 'center')
));
