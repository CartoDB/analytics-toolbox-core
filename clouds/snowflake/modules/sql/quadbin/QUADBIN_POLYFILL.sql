----------------------------
-- Copyright (C) 2021 CARTO
----------------------------


CREATE OR REPLACE FUNCTION @@SF_SCHEMA@@._QUADBIN_POLYFILL_JSINIT
(geojson STRING, resolution DOUBLE)
RETURNS STRING
LANGUAGE JAVASCRIPT
IMMUTABLE
AS $$
    if (!GEOJSON || RESOLUTION == null) {
        throw new Error('NULL argument passed to UDF');
    }

    @@SF_LIBRARY_QUADBIN@@

    const pol = JSON.parse(GEOJSON);
    let quadbins = [];
    if (pol.type == 'GeometryCollection') {
        pol.geometries.forEach(function (geom) {
            quadbins = quadbins.concat(quadbinLib.geojsonToQuadbins(geom, {min_zoom: RESOLUTION, max_zoom: RESOLUTION}));
        });
        quadbins = Array.from(new Set(quadbins));
    }
    else
    {
        quadbins = quadbinLib.geojsonToQuadbins(pol, {min_zoom: RESOLUTION, max_zoom: RESOLUTION});
    }

    return '[' + quadbins.join(',') + ']';
$$;


CREATE OR REPLACE SECURE FUNCTION @@SF_SCHEMA@@._QUADBIN_POLYFILL_INIT
(geog GEOGRAPHY, resolution NUMBER)
RETURNS ARRAY
AS $$
    IFF(geog IS NULL OR resolution IS NULL,
        NULL, (
        IFF(resolution < 0 OR resolution > 26,
            NULL, (
            WITH
            __params AS (
                SELECT
                    resolution AS z,
                    ST_XMIN(geog) AS minlon,
                    ST_YMIN(geog) AS minlat,
                    ST_XMAX(geog) AS maxlon,
                    ST_YMAX(geog) AS maxlat,
                    BITSHIFTLEFT(1::NUMBER, resolution) AS z2,
                    ACOS(-1) AS pi
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
                    BITAND(
                        CAST(
                            FLOOR(z2 * ((minlon / 360.0) + 0.5)) AS NUMBER
                        ),
                        (z2 - 1)   -- bitwise way to calc MODULO
                    ) AS xmin,
                    BITAND(
                        CAST(
                            FLOOR(z2 * ((maxlon / 360.0) + 0.5)) AS NUMBER
                        ),
                        (z2 - 1)   -- bitwise way to calc MODULO
                    ) AS xmax
                FROM __params
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
                        -- floor before cast to avoid up rounding to the next tile
                        FLOOR(
                            z2 * (
                                0.5 - 0.25 * LN(
                                    (1 + sinlat_max) / (1 - sinlat_max)
                                ) / pi
                            )
                        ) AS NUMBER
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
                        ) AS NUMBER
                    )
                    AS ymax

                FROM __params, __xs, __sinlat
            ),
            __cells AS (
                SELECT @@SF_SCHEMA@@.QUADBIN_FROMZXY(z, x.value, y.value) AS quadbin
                FROM __tile_coords_range,
                    lateral FLATTEN(ARRAY_GENERATE_RANGE(xmin, xmax)) AS x,
                    lateral FLATTEN(ARRAY_GENERATE_RANGE(ymin, ymax)) AS y
            )
            SELECT ARRAY_AGG(quadbin)
            FROM __cells
            WHERE ST_INTERSECTS(@@SF_SCHEMA@@.QUADBIN_BOUNDARY(quadbin), geog)
            )
        ))
    )
$$;

-- Utility function to optimize polyfill unzooming and getting childrens
-- of unzoomed parents. Thios would allow server side SQL parallelization
-- NOTE! no intersection is done due to generation of internale error =>
-- cleaning of quadbins have to be done extenally
CREATE OR REPLACE FUNCTION @@SF_SCHEMA@@._QUADBIN_POLYFILL_CHILDRENS
(geog GEOGRAPHY, resolution INT)
RETURNS ARRAY
AS $$
        IFF(geog IS NULL OR resolution IS NULL or NOT ST_ISVALID(geog),
        NULL, (
        IFF(resolution < 0 OR resolution > 26,
            NULL,(
            WITH
                _init AS (
                    SELECT
                        TO_ARRAY(
                            PARSE_JSON(
                                -- Uncomment this line to use ther JS version
                                -- of the POLYFILL init
                                -- @@SF_SCHEMA@@._QUADBIN_POLYFILL_JSINIT(
                                @@SF_SCHEMA@@._QUADBIN_POLYFILL_INIT(
                                    CAST(ST_ASGEOJSON(GEOG) AS STRING),
                                    GREATEST(0, CAST(RESOLUTION-2 AS DOUBLE))
                                )
                            )
                        ) AS quadbins_array
                ),
                _parents AS (
                    SELECT
                        cast(res.value as bigint) AS parent_quadbin
                    FROM
                        _init,
                        lateral FLATTEN(quadbins_array) as res
                ),
                _childrens AS (
                    SELECT
                        @@SF_SCHEMA@@.QUADBIN_TOCHILDREN(parent_quadbin, resolution) as child
                    FROM _parents
                )
                SELECT ARRAY_UNION_AGG(child)
                FROM _childrens
            )
        ))
    )
$$;

CREATE OR REPLACE FUNCTION @@SF_SCHEMA@@._QUADBIN_POLYFILL_CHILDREN_INTERSECTS
(geog GEOGRAPHY, resolution INT)
RETURNS ARRAY
AS $$
        IFF(geog IS NULL OR resolution IS NULL or NOT ST_ISVALID(geog),
        NULL, (
        IFF(resolution < 0 OR resolution > 26,
            NULL,(
            WITH
                _childrens_array AS (
                    SELECT
                        @@SF_SCHEMA@@._QUADBIN_POLYFILL_CHILDRENS(geog, resolution) as child
                ),
                _childrens AS (
                    SELECT
                        res.value AS child
                    FROM
                        _childrens_array,
                        LATERAL FLATTEN(child) AS res
                )
                SELECT ARRAY_UNION_AGG(child)
                FROM _childrens
                WHERE ST_INTERSECTS(geog, @@SF_SCHEMA@@.QUADBIN_BOUNDARY(child))
            )
        ))
    )
$$;

CREATE OR REPLACE FUNCTION @@SF_SCHEMA@@._QUADBIN_POLYFILL_CHILDREN_CONTAINS
(geog GEOGRAPHY, resolution INT)
RETURNS ARRAY
AS $$
        IFF(geog IS NULL OR resolution IS NULL or NOT ST_ISVALID(geog),
        NULL, (
        IFF(resolution < 0 OR resolution > 26,
            NULL,(
            WITH
                _childrens_array AS (
                    SELECT
                        @@SF_SCHEMA@@._QUADBIN_POLYFILL_CHILDRENS(geog, resolution) as child
                ),
                _childrens AS (
                    SELECT
                        res.value AS child
                    FROM
                        _childrens_array,
                        LATERAL FLATTEN(child) AS res
                )
                SELECT ARRAY_UNION_AGG(child)
                FROM _childrens
                WHERE ST_CONTAINS(geog, @@SF_SCHEMA@@.QUADBIN_BOUNDARY(child))
            )
        ))
    )
$$;

CREATE OR REPLACE FUNCTION @@SF_SCHEMA@@._QUADBIN_POLYFILL_CHILDREN_CENTER
(geog GEOGRAPHY, resolution INT)
RETURNS ARRAY
AS $$
    IFF(geog IS NULL OR resolution IS NULL or NOT ST_ISVALID(geog),
        NULL, (
        IFF(resolution < 0 OR resolution > 26,
            NULL,(
            WITH
                _childrens_array AS (
                    SELECT
                        @@SF_SCHEMA@@._QUADBIN_POLYFILL_CHILDRENS(geog, resolution) as child
                ),
                _childrens AS (
                    SELECT
                        res.value AS child
                    FROM
                        _childrens_array,
                        LATERAL FLATTEN(child) AS res
                )
                SELECT ARRAY_UNION_AGG(child)
                FROM _childrens
                WHERE ST_INTERSECTS(geog, @@SF_SCHEMA@@.QUADBIN_CENTER(child))
            )
        ))
    )
$$;

CREATE OR REPLACE FUNCTION @@SF_SCHEMA@@.QUADBIN_POLYFILL
(geog GEOGRAPHY, resolution INT, mode STRING)
RETURNS ARRAY
AS $$
    IFF(geog IS NULL OR resolution IS NULL or NOT ST_ISVALID(geog),
        NULL, (
        IFF(resolution < 0 OR resolution > 26,
            NULL,(
            SELECT
                CASE mode
                    WHEN 'intersects' THEN @@SF_SCHEMA@@._QUADBIN_POLYFILL_CHILDREN_INTERSECTS(geog, resolution)
                    WHEN 'contains' THEN @@SF_SCHEMA@@._QUADBIN_POLYFILL_CHILDREN_CONTAINS(geog, resolution)
                    WHEN 'center' THEN @@SF_SCHEMA@@._QUADBIN_POLYFILL_CHILDREN_CENTER(geog, resolution)
                END
            )
        ))
    )
$$;

CREATE OR REPLACE SECURE FUNCTION @@SF_SCHEMA@@.QUADBIN_POLYFILL
(geog GEOGRAPHY, resolution INT)
RETURNS ARRAY
AS $$
        IFF(geog IS NULL OR resolution IS NULL or NOT ST_ISVALID(geog),
            NULL, (
            IFF(resolution < 0 OR resolution > 26,
                NULL,(
                SELECT
                    @@SF_SCHEMA@@._QUADBIN_POLYFILL_CHILDREN_INTERSECTS(geog, resolution)
                )
            ))
        )
$$;
