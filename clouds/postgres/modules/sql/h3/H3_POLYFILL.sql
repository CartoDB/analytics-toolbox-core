---------------------------------
-- Copyright (C) 2021-2023 CARTO
---------------------------------

CREATE OR REPLACE FUNCTION @@PG_SCHEMA@@.__H3_POLYFILL_GEOJSON(
    geojson TEXT,
    resolution INT
)
RETURNS VARCHAR(16)[]
AS
$BODY$
    @@PG_LIBRARY_H3@@

    const bboxA = [-180, -90, 0, 90]
    const bboxB = [0, -90, 180, 90]
    const featureGeometry = JSON.parse(geojson)
    let polygonCoordinatesA = []
    let polygonCoordinatesB = []
    switch(featureGeometry.type) {
        case 'GeometryCollection':
            featureGeometry.geometries.forEach(function (geom) {
                if (geom.type === 'MultiPolygon') {
                    var clippedGeometryA = h3Lib.bboxClip(geom, bboxA).geometry
                    polygonCoordinatesA = polygonCoordinatesA.concat(clippedGeometryA.coordinates)
                    var clippedGeometryB = h3Lib.bboxClip(geom, bboxB).geometry
                    polygonCoordinatesB = polygonCoordinatesB.concat(clippedGeometryB.coordinates)
                } else if (geom.type === 'Polygon') {
                    var clippedGeometryA = h3Lib.bboxClip(geom, bboxA).geometry
                    polygonCoordinatesA = polygonCoordinatesA.concat([clippedGeometryA.coordinates])
                    var clippedGeometryB = h3Lib.bboxClip(geom, bboxB).geometry
                    polygonCoordinatesB = polygonCoordinatesB.concat([clippedGeometryB.coordinates])
                }
            })
        break
        case 'MultiPolygon':
            var clippedGeometryA = h3Lib.bboxClip(featureGeometry, bboxA).geometry
            polygonCoordinatesA = clippedGeometryA.coordinates
            var clippedGeometryB = h3Lib.bboxClip(featureGeometry, bboxB).geometry
            polygonCoordinatesB = clippedGeometryB.coordinates
        break
        case 'Polygon':
            var clippedGeometryA = h3Lib.bboxClip(featureGeometry, bboxA).geometry
            polygonCoordinatesA = [clippedGeometryA.coordinates]
            var clippedGeometryB = h3Lib.bboxClip(featureGeometry, bboxB).geometry
            polygonCoordinatesB = [clippedGeometryB.coordinates]
        break
        default:
            return null
    }

    if (polygonCoordinatesA.length + polygonCoordinatesB.length === 0) {
        return null;
    }

    let hexesA = polygonCoordinatesA.reduce(
        (acc, coordinates) => acc.concat(h3Lib.polyfill(coordinates, resolution, true)),
        []
    ).filter(h => h != null)
    let hexesB = polygonCoordinatesB.reduce(
        (acc, coordinates) => acc.concat(h3Lib.polyfill(coordinates, resolution, true)),
        []
    ).filter(h => h != null)
    hexes = [...hexesA, ...hexesB]
    hexes = [...new Set(hexes)]

    return hexes
$BODY$
LANGUAGE plv8 IMMUTABLE PARALLEL SAFE;

CREATE OR REPLACE FUNCTION @@PG_SCHEMA@@.__H3_AVG_EDGE_LENGTH(
    resolution INT
)
RETURNS NUMERIC
AS
$BODY$
    -- https://h3geo.org/docs/core-library/restable/#edge-lengths
    SELECT CASE resolution
        WHEN 0 THEN 1281256.011
        WHEN 1 THEN 483056.8391
        WHEN 2 THEN 182512.9565
        WHEN 3 THEN 68979.22179
        WHEN 4 THEN 26071.75968
        WHEN 5 THEN 9854.090990
        WHEN 6 THEN 3724.532667
        WHEN 7 THEN 1406.475763
        WHEN 8 THEN 531.414010
        WHEN 9 THEN 200.786148
        WHEN 10 THEN 75.863783
        WHEN 11 THEN 28.663897
        WHEN 12 THEN 10.830188
        WHEN 13 THEN 4.092010
        WHEN 14 THEN 1.546100
        WHEN 15 THEN 0.584169
    END
$BODY$
LANGUAGE sql IMMUTABLE PARALLEL SAFE;

CREATE OR REPLACE FUNCTION @@PG_SCHEMA@@.__H3_AVG_HEXAGON_AREA(
    resolution INT
)
RETURNS NUMERIC
AS
$BODY$
    -- https://h3geo.org/docs/core-library/restable/#average-area-in-m2
    SELECT CASE resolution
        WHEN 0 THEN 4357449416078.392
        WHEN 1 THEN 609788441794.134
        WHEN 2 THEN 86801780398.997
        WHEN 3 THEN 12393434655.088
        WHEN 4 THEN 1770347654.491
        WHEN 5 THEN 252903858.182
        WHEN 6 THEN 36129062.164
        WHEN 7 THEN 5161293.360
        WHEN 8 THEN 737327.598
        WHEN 9 THEN 105332.513
        WHEN 10 THEN 15047.502
        WHEN 11 THEN 2149.643
        WHEN 12 THEN 307.092
        WHEN 13 THEN 43.870
        WHEN 14 THEN 6.267
        WHEN 15 THEN 0.895
    END
$BODY$
LANGUAGE sql IMMUTABLE PARALLEL SAFE;

CREATE OR REPLACE FUNCTION @@PG_SCHEMA@@.__H3_POLYFILL_INIT(
    geom GEOMETRY,
    resolution INT
)
RETURNS VARCHAR(16)[]
AS
$BODY$
    SELECT CASE
        WHEN resolution IS NULL OR geom IS NULL THEN NULL::VARCHAR(16)[]
        WHEN resolution < 0 OR resolution > 26 THEN @@PG_SCHEMA@@.__CARTO_ERROR(FORMAT('Invalid resolution "%s"; should be between 0 and 26', resolution))::VARCHAR(16)[]
        ELSE @@PG_SCHEMA@@.__H3_POLYFILL_GEOJSON(
                ST_ASGEOJSON(
                    ST_BUFFER(geom::GEOGRAPHY, @@PG_SCHEMA@@.__H3_AVG_EDGE_LENGTH(resolution))::GEOMETRY
                ),
                resolution
            )
        END
$BODY$
LANGUAGE sql IMMUTABLE PARALLEL SAFE;

-- __H3_POLYFILL_INIT_BBOX
-- __H3_POLYFILL_INIT_SIMP

CREATE OR REPLACE FUNCTION @@PG_SCHEMA@@.__H3_POLYFILL_INIT_Z(
    geom GEOMETRY,
    resolution INT
)
RETURNS INT
AS
$BODY$
    WITH __params AS (
        SELECT ST_AREA(geom) AS geom_area,
            @@PG_SCHEMA@@.__H3_AVG_HEXAGON_AREA(resolution) AS cell_area
    )
    -- return the min value between the target and intermediate resolutions
    SELECT LEAST(
        resolution,
        -- compute the resolution of cells that match the geog area
        -- by comparing with the area of the cell, plus 3 levels
        (CASE
            WHEN geom_area > 0 THEN resolution - CAST(LOG(7::NUMERIC, (geom_area/cell_area)::NUMERIC) AS INT) + 3
            ELSE resolution
        END))
    FROM __params
$BODY$
LANGUAGE sql IMMUTABLE PARALLEL SAFE;

CREATE OR REPLACE FUNCTION @@PG_SCHEMA@@.__H3_POLYFILL_CHILDREN_INTERSECTS(
    geom GEOMETRY,
    resolution INT
)
RETURNS VARCHAR(16)[]
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
        SELECT h3
        FROM __geom4326,
            UNNEST(@@PG_SCHEMA@@.__H3_POLYFILL_INIT(geom4326,
                @@PG_SCHEMA@@.__H3_POLYFILL_INIT_Z(geom4326, resolution))) AS parent,
            UNNEST(@@PG_SCHEMA@@.H3_TOCHILDREN(parent, resolution)) AS h3
    )
    SELECT ARRAY_AGG(h3)
    FROM __cells, __geom4326
    WHERE ST_INTERSECTS(geom4326, ST_SETSRID(@@PG_SCHEMA@@.H3_BOUNDARY(h3), 4326))
$BODY$
LANGUAGE sql IMMUTABLE PARALLEL SAFE;

CREATE OR REPLACE FUNCTION @@PG_SCHEMA@@.__H3_POLYFILL_CHILDREN_CONTAINS(
    geom GEOMETRY,
    resolution INT
)
RETURNS VARCHAR(16)[]
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
        SELECT h3
        FROM __geom4326,
            UNNEST(@@PG_SCHEMA@@.__H3_POLYFILL_INIT(geom4326,
                @@PG_SCHEMA@@.__H3_POLYFILL_INIT_Z(geom4326, resolution))) AS parent,
            UNNEST(@@PG_SCHEMA@@.H3_TOCHILDREN(parent, resolution)) AS h3
    )
    SELECT ARRAY_AGG(h3)
    FROM __cells, __geom4326
    WHERE ST_CONTAINS(geom4326, ST_SETSRID(@@PG_SCHEMA@@.H3_BOUNDARY(h3), 4326))
$BODY$
LANGUAGE sql IMMUTABLE PARALLEL SAFE;

CREATE OR REPLACE FUNCTION @@PG_SCHEMA@@.__H3_POLYFILL_CHILDREN_CENTER(
    geom GEOMETRY,
    resolution INT
)
RETURNS VARCHAR(16)[]
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
        SELECT h3
        FROM __geom4326,
            UNNEST(@@PG_SCHEMA@@.__H3_POLYFILL_INIT(geom4326,
                @@PG_SCHEMA@@.__H3_POLYFILL_INIT_Z(geom4326, resolution))) AS parent,
            UNNEST(@@PG_SCHEMA@@.H3_TOCHILDREN(parent, resolution)) AS h3
    )
    SELECT ARRAY_AGG(h3)
    FROM __cells, __geom4326
    WHERE ST_INTERSECTS(geom4326, ST_SETSRID(@@PG_SCHEMA@@.H3_CENTER(h3), 4326))
$BODY$
LANGUAGE sql IMMUTABLE PARALLEL SAFE;

CREATE OR REPLACE FUNCTION @@PG_SCHEMA@@.H3_POLYFILL(
    geom GEOMETRY,
    resolution INTEGER,
    mode TEXT
)
RETURNS VARCHAR(16)[]
AS
$BODY$
    SELECT CASE mode
        WHEN 'intersects' THEN @@PG_SCHEMA@@.__H3_POLYFILL_CHILDREN_INTERSECTS(geom, resolution)
        WHEN 'contains' THEN @@PG_SCHEMA@@.__H3_POLYFILL_CHILDREN_CONTAINS(geom, resolution)
        WHEN 'center' THEN @@PG_SCHEMA@@.__H3_POLYFILL_CHILDREN_CENTER(geom, resolution)
    END
$BODY$
LANGUAGE sql IMMUTABLE PARALLEL SAFE;

CREATE OR REPLACE FUNCTION @@PG_SCHEMA@@.H3_POLYFILL(
    geom GEOMETRY,
    resolution INTEGER
)
RETURNS VARCHAR(16)[]
AS
$BODY$
    SELECT @@PG_SCHEMA@@.__H3_POLYFILL_CHILDREN_CENTER(geom, resolution)
$BODY$
LANGUAGE sql IMMUTABLE PARALLEL SAFE;
