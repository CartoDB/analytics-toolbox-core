---------------------------------
-- Copyright (C) 2022-2023 CARTO
---------------------------------

CREATE OR REPLACE FUNCTION `@@BQ_DATASET@@.__QUADBIN_POLYFILL_INIT`
(geog GEOGRAPHY, resolution INT64)
RETURNS ARRAY<INT64>
AS ((
    IF(geog IS NULL OR resolution IS NULL,
        NULL,
        IF(resolution < 0 OR resolution > 26,
            ERROR('Invalid resolution, should be between 0 and 26'), (
            WITH __bbox AS (
                SELECT ST_BOUNDINGBOX(geog) AS box
            ),
            __params AS (
                SELECT
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
            __tile_coords_range AS (
                SELECT
                    resolution AS z,
                    CAST(
                        FLOOR(z2 * ((minlon / 360.0) + 0.5)) AS INT64
                    ) AS xmin,
                    CAST(
                        FLOOR(
                            z2 * (
                                0.5 - 0.25 * LN(
                                    (1 + sinlat_max) / (1 - sinlat_max)
                                ) / pi
                            )
                        ) AS INT64
                    ) AS ymin,
                    CAST(
                        FLOOR(z2 * ((maxlon / 360.0) + 0.5)) AS INT64
                    ) AS xmax,
                    CAST(
                        FLOOR(
                            z2 * (
                                0.5 - 0.25 * LN(
                                    (1 + sinlat_min) / (1 - sinlat_min)
                                ) / pi
                            )
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
        ))
    )
));

CREATE OR REPLACE FUNCTION `@@BQ_DATASET@@.__QUADBIN_POLYFILL_INIT_Z`
(geog GEOGRAPHY, resolution INT64)
RETURNS INT64
AS ((
    WITH __params AS (
        SELECT ST_AREA(geog) AS geog_area
    )
    -- return the min value between the target and intermediate
    -- resolutions to return between 1 and 256 cells
    SELECT LEAST(
        resolution,
        -- compute the resolution of cells that match the geog area
        -- by comparing with the area of the quadbin 0, plus 3 levels
        IF(geog_area > 0, CAST(-LOG(geog_area / 508164597540055.75, 4) AS INT64) + 3, resolution))
    FROM __params
));

CREATE OR REPLACE FUNCTION `@@BQ_DATASET@@.__QUADBIN_POLYFILL_CHILDREN_INTERSECTS`
(geog GEOGRAPHY, resolution INT64)
RETURNS ARRAY<INT64>
AS ((
    WITH __cells AS (
        SELECT quadbin
        FROM UNNEST(`@@BQ_DATASET@@.__QUADBIN_POLYFILL_INIT`(geog,
                `@@BQ_DATASET@@.__QUADBIN_POLYFILL_INIT_Z`(geog, resolution))) AS parent,
            UNNEST(`@@BQ_DATASET@@.QUADBIN_TOCHILDREN`(parent, resolution)) AS quadbin
    )
    SELECT ARRAY_AGG(quadbin)
    FROM __cells
    WHERE ST_INTERSECTS(geog, `@@BQ_DATASET@@.QUADBIN_BOUNDARY`(quadbin))
));

CREATE OR REPLACE FUNCTION `@@BQ_DATASET@@.__QUADBIN_POLYFILL_CHILDREN_CONTAINS`
(geog GEOGRAPHY, resolution INT64)
RETURNS ARRAY<INT64>
AS ((
    WITH __cells AS (
        SELECT quadbin
        FROM UNNEST(`@@BQ_DATASET@@.__QUADBIN_POLYFILL_INIT`(geog,
                `@@BQ_DATASET@@.__QUADBIN_POLYFILL_INIT_Z`(geog, resolution))) AS parent,
            UNNEST(`@@BQ_DATASET@@.QUADBIN_TOCHILDREN`(parent, resolution)) AS quadbin
    )
    SELECT ARRAY_AGG(quadbin)
    FROM __cells
    WHERE ST_CONTAINS(geog, `@@BQ_DATASET@@.QUADBIN_BOUNDARY`(quadbin))
));

CREATE OR REPLACE FUNCTION `@@BQ_DATASET@@.__QUADBIN_POLYFILL_CHILDREN_CENTER`
(geog GEOGRAPHY, resolution INT64)
RETURNS ARRAY<INT64>
AS ((
    WITH __cells AS (
        SELECT quadbin
        FROM UNNEST(`@@BQ_DATASET@@.__QUADBIN_POLYFILL_INIT`(geog,
                `@@BQ_DATASET@@.__QUADBIN_POLYFILL_INIT_Z`(geog, resolution))) AS parent,
            UNNEST(`@@BQ_DATASET@@.QUADBIN_TOCHILDREN`(parent, resolution)) AS quadbin
    )
    SELECT ARRAY_AGG(quadbin)
    FROM __cells
    WHERE ST_INTERSECTS(geog, `@@BQ_DATASET@@.QUADBIN_CENTER`(quadbin))
));

CREATE OR REPLACE FUNCTION `@@BQ_DATASET@@.QUADBIN_POLYFILL_MODE`
(geog GEOGRAPHY, resolution INT64, mode STRING)
RETURNS ARRAY<INT64>
AS ((
    CASE mode
        WHEN 'intersects' THEN `@@BQ_DATASET@@.__QUADBIN_POLYFILL_CHILDREN_INTERSECTS`(geog, resolution)
        WHEN 'contains' THEN `@@BQ_DATASET@@.__QUADBIN_POLYFILL_CHILDREN_CONTAINS`(geog, resolution)
        WHEN 'center' THEN `@@BQ_DATASET@@.__QUADBIN_POLYFILL_CHILDREN_CENTER`(geog, resolution)
    END
));

CREATE OR REPLACE FUNCTION `@@BQ_DATASET@@.QUADBIN_POLYFILL`
(geog GEOGRAPHY, resolution INT64)
RETURNS ARRAY<INT64>
AS ((
    `@@BQ_DATASET@@.__QUADBIN_POLYFILL_CHILDREN_CENTER`(geog, resolution)
));
