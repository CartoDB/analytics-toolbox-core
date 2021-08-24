----------------------------
-- Copyright (C) 2021 CARTO
----------------------------

CREATE OR REPLACE FUNCTION `@@BQ_PREFIX@@h3.__ST_ASH3_POLYFILL`
(geojson STRING, _resolution INT64)
RETURNS ARRAY<STRING>
DETERMINISTIC
LANGUAGE js
OPTIONS (library=["@@BQ_LIBRARY_BUCKET@@"])
AS """
    if (!geojson || _resolution == null) {
        return null;
    }

    const resolution = Number(_resolution);
    if (resolution < 0 || resolution > 15) {
        return null;
    }

    const featureGeometry = JSON.parse(geojson)
    let polygonCoordinates = [];
    switch(featureGeometry.type) {
        case 'GeometryCollection':
            featureGeometry.geometries.forEach(function (geom) {
                if (geom.type === 'MultiPolygon') {
                    polygonCoordinates = polygonCoordinates.concat(geom.coordinates);
                } else if (geom.type === 'Polygon') {
                    polygonCoordinates = polygonCoordinates.concat([geom.coordinates]);
                }
            });
        break;
        case 'MultiPolygon':
            polygonCoordinates = featureGeometry.coordinates;
        break;
        case 'Polygon':
            polygonCoordinates = [featureGeometry.coordinates];
        break;
        default:
            return null;
    }

    if (polygonCoordinates.length === 0) {
        return null;
    }

    let hexes = polygonCoordinates.reduce(
        (acc, coordinates) => acc.concat(h3Lib.polyfill(coordinates, resolution, true)),
        []
    ).filter(h => h != null);
    hexes = [...new Set(hexes)];

    return hexes;
""";

CREATE OR REPLACE FUNCTION `@@BQ_PREFIX@@h3.ST_ASH3_POLYFILL`
(geog GEOGRAPHY, resolution INT64)
RETURNS ARRAY<STRING>
AS (
    `@@BQ_PREFIX@@h3.__ST_ASH3_POLYFILL`(ST_ASGEOJSON(geog), resolution)
);