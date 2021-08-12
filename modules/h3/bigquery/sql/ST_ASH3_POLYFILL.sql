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
    if (!['Polygon', 'MultiPolygon', 'GeometryCollection'].includes(featureGeometry.type)) {
        return null;
    }

    let polygonCoordinates = [];
    if (featureGeometry.type === 'GeometryCollection') {
        featureGeometry.geometries.forEach(function (geom) {
            if (geom.type === 'MultiPolygon') {
                polygonCoordinates.push(geom.coordinates);
            } else if (geom.type === 'Polygon') {
                polygonCoordinates.push([geom.coordinates]);
            }
        });
    } else if (featureGeometry.type === 'MultiPolygon') {
        polygonCoordinates = featureGeometry.coordinates;
    } else {
        polygonCoordinates = [featureGeometry.coordinates];
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