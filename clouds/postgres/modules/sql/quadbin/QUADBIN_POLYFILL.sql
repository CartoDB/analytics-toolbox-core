---------------------------------
-- Copyright (C) 2022-2023 CARTO
---------------------------------

CREATE OR REPLACE FUNCTION @@PG_SCHEMA@@.__QUADBIN_POLYFILL_INIT_TABLE(
    geom GEOMETRY,
    resolution INT
)
RETURNS TABLE (quadbin BIGINT)
AS
$BODY$
    WITH __bbox AS (
        SELECT BOX2D(geom) AS b
    ),
    __params AS (
        SELECT
            ST_XMIN(b) AS minlon,
            ST_YMIN(b) AS minlat,
            ST_XMAX(b) AS maxlon,
            ST_YMAX(b) AS maxlat,
            (1::BIGINT << resolution) AS z2
        FROM __bbox
    ),
    __sinlat AS (
        SELECT
            SIN(minlat * PI() / 180.0) AS sinlat_min,
            SIN(maxlat * PI() / 180.0) AS sinlat_max
        FROM __params
    ),
    __tile_coords_range AS (
        SELECT
            resolution AS z,
            FLOOR(z2 * ((minlon / 360.0) + 0.5))::INT AS xmin,
            FLOOR(
                z2 * (
                    0.5 - 0.25 * LN(
                        (1 + sinlat_max) / (1 - sinlat_max)
                    ) / PI()
                )
            )::INT AS ymin,
            FLOOR(z2 * ((maxlon / 360.0) + 0.5))::INT AS xmax,
            FLOOR(
                z2 * (
                    0.5 - 0.25 * LN(
                        (1 + sinlat_min) / (1 - sinlat_min)
                    ) / PI()
                )
            )::INT AS ymax
        FROM __params, __sinlat
    ),
    -- compute all the quadbin cells contained in the bounding box
    __cells AS (
        SELECT @@PG_SCHEMA@@.QUADBIN_FROMZXY(z, x, y) AS quadbin
        FROM __tile_coords_range,
            GENERATE_SERIES(xmin, xmax) AS x,
            GENERATE_SERIES(ymin, ymax) AS y
    )
    SELECT quadbin
    FROM __cells
$BODY$
LANGUAGE sql IMMUTABLE PARALLEL SAFE;

CREATE OR REPLACE FUNCTION @@PG_SCHEMA@@.__QUADBIN_POLYFILL_INIT(
    geom GEOMETRY,
    resolution INT
)
RETURNS BIGINT[]
AS
$BODY$
    SELECT ARRAY_AGG(quadbin)
    FROM @@PG_SCHEMA@@.__QUADBIN_POLYFILL_INIT_TABLE(geom, resolution)
    WHERE ST_INTERSECTS(geom, @@PG_SCHEMA@@.QUADBIN_BOUNDARY(quadbin))
$BODY$
LANGUAGE sql IMMUTABLE PARALLEL SAFE;

CREATE OR REPLACE FUNCTION @@PG_SCHEMA@@.__QUADBIN_POLYFILL_INIT_Z(
    geom GEOMETRY,
    resolution INT
)
RETURNS INT
AS
$BODY$
    WITH __params AS (
        SELECT ST_AREA(geom) AS geom_area
    )
    -- compute the resolution of cells that match the geog area
    -- by comparing with the area of the quadbin 0, plus 3 levels
    SELECT CASE
        WHEN geom_area > 0 THEN CAST(-LOG(4::NUMERIC, (geom_area/61236.812721460745)::NUMERIC) AS INT) + 3
        ELSE resolution
    END
    FROM __params
$BODY$
LANGUAGE sql IMMUTABLE PARALLEL SAFE;

CREATE OR REPLACE FUNCTION @@PG_SCHEMA@@.__QUADBIN_POLYFILL_CHILDREN_INTERSECTS(
    geom GEOMETRY,
    resolution INT
)
RETURNS BIGINT[]
AS
$BODY$
    WITH __params AS (
        SELECT @@PG_SCHEMA@@.__QUADBIN_POLYFILL_INIT_Z(geom, resolution) AS init_z
    )
    SELECT CASE
        WHEN resolution < init_z + 2
        THEN
            (SELECT ARRAY_AGG(quadbin)
            FROM @@PG_SCHEMA@@.__QUADBIN_POLYFILL_INIT_TABLE(geom, resolution)
            WHERE ST_INTERSECTS(geom, @@PG_SCHEMA@@.QUADBIN_BOUNDARY(quadbin)))
        ELSE
            (WITH __cells AS (
                SELECT quadbin
                FROM UNNEST(@@PG_SCHEMA@@.__QUADBIN_POLYFILL_INIT(geom, init_z)) AS parent,
                    UNNEST(@@PG_SCHEMA@@.QUADBIN_TOCHILDREN(parent, resolution)) AS quadbin
            )
            SELECT ARRAY_AGG(quadbin)
            FROM __cells
            WHERE ST_INTERSECTS(geom, @@PG_SCHEMA@@.QUADBIN_BOUNDARY(quadbin)))
    END
    FROM __params
$BODY$
LANGUAGE sql IMMUTABLE PARALLEL SAFE;

CREATE OR REPLACE FUNCTION @@PG_SCHEMA@@.__QUADBIN_POLYFILL_CHILDREN_CONTAINS(
    geom GEOMETRY,
    resolution INT
)
RETURNS BIGINT[]
AS
$BODY$
    WITH __params AS (
        SELECT @@PG_SCHEMA@@.__QUADBIN_POLYFILL_INIT_Z(geom, resolution) AS init_z
    )
    SELECT CASE
        WHEN resolution < init_z + 2
        THEN
            (SELECT ARRAY_AGG(quadbin)
            FROM @@PG_SCHEMA@@.__QUADBIN_POLYFILL_INIT_TABLE(geom, resolution)
            WHERE ST_CONTAINS(geom, @@PG_SCHEMA@@.QUADBIN_BOUNDARY(quadbin)))
        ELSE
            (WITH __cells AS (
                SELECT quadbin
                FROM UNNEST(@@PG_SCHEMA@@.__QUADBIN_POLYFILL_INIT(geom, init_z)) AS parent,
                    UNNEST(@@PG_SCHEMA@@.QUADBIN_TOCHILDREN(parent, resolution)) AS quadbin
            )
            SELECT ARRAY_AGG(quadbin)
            FROM __cells
            WHERE ST_CONTAINS(geom, @@PG_SCHEMA@@.QUADBIN_BOUNDARY(quadbin)))
    END
    FROM __params
$BODY$
LANGUAGE sql IMMUTABLE PARALLEL SAFE;

CREATE OR REPLACE FUNCTION @@PG_SCHEMA@@.__QUADBIN_POLYFILL_CHILDREN_CENTER(
    geom GEOMETRY,
    resolution INT
)
RETURNS BIGINT[]
AS
$BODY$
    WITH __params AS (
        SELECT @@PG_SCHEMA@@.__QUADBIN_POLYFILL_INIT_Z(geom, resolution) AS init_z
    )
    SELECT CASE
        WHEN resolution < init_z + 2
        THEN
            (SELECT ARRAY_AGG(quadbin)
            FROM @@PG_SCHEMA@@.__QUADBIN_POLYFILL_INIT_TABLE(geom, resolution)
            WHERE ST_INTERSECTS(geom, @@PG_SCHEMA@@.QUADBIN_CENTER(quadbin)))
        ELSE
            (WITH __cells AS (
                SELECT quadbin
                FROM UNNEST(@@PG_SCHEMA@@.__QUADBIN_POLYFILL_INIT(geom, init_z)) AS parent,
                    UNNEST(@@PG_SCHEMA@@.QUADBIN_TOCHILDREN(parent, resolution)) AS quadbin
            )
            SELECT ARRAY_AGG(quadbin)
            FROM __cells
            WHERE ST_INTERSECTS(geom, @@PG_SCHEMA@@.QUADBIN_CENTER(quadbin)))
    END
    FROM __params
$BODY$
LANGUAGE sql IMMUTABLE PARALLEL SAFE;

CREATE OR REPLACE FUNCTION @@PG_SCHEMA@@.QUADBIN_POLYFILL(
    geom GEOMETRY,
    resolution INT,
    mode VARCHAR
)
RETURNS BIGINT[]
AS
$BODY$
    SELECT CASE
        WHEN resolution IS NULL OR geom IS NULL THEN NULL::BIGINT[]
        WHEN resolution < 0 OR resolution > 26 THEN @@PG_SCHEMA@@.__CARTO_ERROR(FORMAT('Invalid resolution "%s"; should be between 0 and 26', resolution))::BIGINT[]
        ELSE (WITH __geom4326 AS (
                SELECT
                    (CASE ST_SRID(geom)
                        WHEN 0 THEN ST_SETSRID(geom, 4326)
                        ELSE ST_TRANSFORM(geom, 4326)
                    END) AS geom4326
            )
            SELECT CASE mode
                WHEN 'intersects' THEN @@PG_SCHEMA@@.__QUADBIN_POLYFILL_CHILDREN_INTERSECTS(geom4326, resolution)
                WHEN 'contains' THEN @@PG_SCHEMA@@.__QUADBIN_POLYFILL_CHILDREN_CONTAINS(geom4326, resolution)
                WHEN 'center' THEN @@PG_SCHEMA@@.__QUADBIN_POLYFILL_CHILDREN_CENTER(geom4326, resolution)
            END
            FROM __geom4326)
    END
$BODY$
LANGUAGE sql IMMUTABLE PARALLEL SAFE;

CREATE OR REPLACE FUNCTION @@PG_SCHEMA@@.QUADBIN_POLYFILL(
    geom GEOMETRY,
    resolution INT
)
RETURNS BIGINT[]
AS
$BODY$
    SELECT @@PG_SCHEMA@@.QUADBIN_POLYFILL(geom, resolution, 'center')
$BODY$
LANGUAGE sql IMMUTABLE PARALLEL SAFE;

CREATE OR REPLACE FUNCTION @@PG_SCHEMA@@.__QUADBIN_POLYFILL_INIT_Z(
    geom GEOMETRY,
    resolution INT
)
RETURNS INT
AS
$BODY$
    WITH __params AS (
        SELECT ST_AREA(geom) AS geom_area
    )
    -- return the min value between the target and intermediate
    -- resolutions to return between 1 and 256 cells
    SELECT LEAST(
        resolution,
        -- compute the resolution of cells that match the geog area
        -- by comparing with the area of the quadbin 0, plus 3 levels
        (CASE
            WHEN geom_area > 0 THEN CAST(-LOG(4::NUMERIC, (geom_area/61236.812721460745)::NUMERIC) AS INT) + 3
            ELSE resolution
        END))
    FROM __params
$BODY$
LANGUAGE sql IMMUTABLE PARALLEL SAFE;

CREATE OR REPLACE FUNCTION @@PG_SCHEMA@@.__QUADBIN_POLYFILL_CHILDREN_INTERSECTS(
    geom GEOMETRY,
    resolution INT
)
RETURNS BIGINT[]
AS
$BODY$
    WITH __geom4326 AS (
        SELECT
            (CASE ST_SRID(geom)
                WHEN 0 THEN ST_SETSRID(geom, 4326)
                ELSE ST_TRANSFORM(geom, 4326)
            END) AS geom4326
    ),
    __cells AS (
        SELECT quadbin
        FROM __geom4326,
             UNNEST(@@PG_SCHEMA@@.__QUADBIN_POLYFILL_INIT(geom4326,
                @@PG_SCHEMA@@.__QUADBIN_POLYFILL_INIT_Z(geom4326, resolution))) AS parent,
             UNNEST(@@PG_SCHEMA@@.QUADBIN_TOCHILDREN(parent, resolution)) AS quadbin
    )
    SELECT ARRAY_AGG(quadbin)
    FROM __cells, __geom4326
    WHERE ST_INTERSECTS(geom4326, @@PG_SCHEMA@@.QUADBIN_BOUNDARY(quadbin));
$BODY$
LANGUAGE sql IMMUTABLE PARALLEL SAFE;

CREATE OR REPLACE FUNCTION @@PG_SCHEMA@@.__QUADBIN_POLYFILL_CHILDREN_CONTAINS(
    geom GEOMETRY,
    resolution INT
)
RETURNS BIGINT[]
AS
$BODY$
    WITH __geom4326 AS (
        SELECT
            (CASE ST_SRID(geom)
                WHEN 0 THEN ST_SETSRID(geom, 4326)
                ELSE ST_TRANSFORM(geom, 4326)
            END) AS geom4326
    ),
    __cells AS (
        SELECT quadbin
        FROM __geom4326,
             UNNEST(@@PG_SCHEMA@@.__QUADBIN_POLYFILL_INIT(geom4326,
                @@PG_SCHEMA@@.__QUADBIN_POLYFILL_INIT_Z(geom4326, resolution))) AS parent,
             UNNEST(@@PG_SCHEMA@@.QUADBIN_TOCHILDREN(parent, resolution)) AS quadbin
    )
    SELECT ARRAY_AGG(quadbin)
    FROM __cells, __geom4326
    WHERE ST_CONTAINS(geom4326, @@PG_SCHEMA@@.QUADBIN_BOUNDARY(quadbin))
$BODY$
LANGUAGE sql IMMUTABLE PARALLEL SAFE;

CREATE OR REPLACE FUNCTION @@PG_SCHEMA@@.__QUADBIN_POLYFILL_CHILDREN_CENTER(
    geom GEOMETRY,
    resolution INT
)
RETURNS BIGINT[]
AS
$BODY$
    WITH __geom4326 AS (
        SELECT
            (CASE ST_SRID(geom)
                WHEN 0 THEN ST_SETSRID(geom, 4326)
                ELSE ST_TRANSFORM(geom, 4326)
            END) AS geom4326
    ),
    __cells AS (
        SELECT quadbin
        FROM __geom4326,
             UNNEST(@@PG_SCHEMA@@.__QUADBIN_POLYFILL_INIT(geom4326,
                @@PG_SCHEMA@@.__QUADBIN_POLYFILL_INIT_Z(geom4326, resolution))) AS parent,
             UNNEST(@@PG_SCHEMA@@.QUADBIN_TOCHILDREN(parent, resolution)) AS quadbin
    )
    SELECT ARRAY_AGG(quadbin)
    FROM __cells, __geom4326
    WHERE ST_INTERSECTS(geom4326, @@PG_SCHEMA@@.QUADBIN_CENTER(quadbin))
$BODY$
LANGUAGE sql IMMUTABLE PARALLEL SAFE;

CREATE OR REPLACE FUNCTION @@PG_SCHEMA@@.QUADBIN_POLYFILL(
    geom GEOMETRY,
    resolution INT,
    mode VARCHAR
)
RETURNS BIGINT[]
AS
$BODY$
    SELECT CASE mode
        WHEN 'intersects' THEN @@PG_SCHEMA@@.__QUADBIN_POLYFILL_CHILDREN_INTERSECTS(geom, resolution)
        WHEN 'contains' THEN @@PG_SCHEMA@@.__QUADBIN_POLYFILL_CHILDREN_CONTAINS(geom, resolution)
        WHEN 'center' THEN @@PG_SCHEMA@@.__QUADBIN_POLYFILL_CHILDREN_CENTER(geom, resolution)
    END
$BODY$
LANGUAGE sql IMMUTABLE PARALLEL SAFE;

CREATE OR REPLACE FUNCTION @@PG_SCHEMA@@.QUADBIN_POLYFILL(
    geom GEOMETRY,
    resolution INT
)
RETURNS BIGINT[]
AS
$BODY$
    SELECT @@PG_SCHEMA@@.__QUADBIN_POLYFILL_CHILDREN_CENTER(geom, resolution)
$BODY$
LANGUAGE sql IMMUTABLE PARALLEL SAFE;
