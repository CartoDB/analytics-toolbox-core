-----------------------------------------------------------------------
--
-- Copyright (C) 2021 CARTO
--
-----------------------------------------------------------------------

CREATE OR REPLACE FUNCTION `@@BQ_PROJECTID@@.@@BQ_DATASET_H3@@.LONGLAT_ASH3`(longitude FLOAT64, latitude FLOAT64, resolution INT64)
    RETURNS STRING
    DETERMINISTIC
    LANGUAGE js
    OPTIONS (library=["@@H3_BQ_LIBRARY@@"])
AS
"""
    if (longitude === null || latitude === null || resolution === null) {
        return null;
    }
    const index = h3.geoToH3(Number(latitude), Number(longitude), Number(resolution));
    return index;
""";

CREATE OR REPLACE FUNCTION `@@BQ_PROJECTID@@.@@BQ_DATASET_H3@@.ST_ASH3`(geog GEOGRAPHY, resolution INT64)
    RETURNS STRING
AS
(
    `@@BQ_PROJECTID@@.@@BQ_DATASET_H3@@.LONGLAT_ASH3`(SAFE.ST_X(geog), SAFE.ST_Y(geog), resolution)
);

CREATE OR REPLACE FUNCTION `@@BQ_PROJECTID@@.@@BQ_DATASET_H3@@.__ST_ASH3_POLYFILL`(geojson STRING, _resolution INT64)
    RETURNS ARRAY<STRING>
    DETERMINISTIC
    LANGUAGE js
    OPTIONS (library=["@@H3_BQ_LIBRARY@@"])
AS
"""
    if (!geojson || _resolution == null) {
        return null;
    }

    const resolution = Number(_resolution);
    if (resolution < 0 || resolution > 15) {
        return null;
    }

    const featureGeometry = JSON.parse(geojson)
    if (!['Polygon', 'MultiPolygon'].includes(featureGeometry.type)) {
        return null;
    }

    const polygonCoordinates =  featureGeometry.type === 'MultiPolygon' ? featureGeometry.coordinates : [featureGeometry.coordinates];
    let hexes = polygonCoordinates.reduce(
        (acc, coordinates) => acc.concat(h3.polyfill(coordinates, resolution, true)),
        []
    ).filter(h => h != null);
    hexes = [...new Set(hexes)];

    return hexes;
""";

CREATE OR REPLACE FUNCTION `@@BQ_PROJECTID@@.@@BQ_DATASET_H3@@.ST_ASH3_POLYFILL`(geog GEOGRAPHY, resolution INT64)
    RETURNS ARRAY<STRING>
AS
(
    `@@BQ_PROJECTID@@.@@BQ_DATASET_H3@@.__ST_ASH3_POLYFILL`(ST_ASGEOJSON(geog), resolution)
);