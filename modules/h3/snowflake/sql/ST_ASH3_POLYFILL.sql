----------------------------
-- Copyright (C) 2021 CARTO
----------------------------

CREATE OR REPLACE FUNCTION @@SF_PREFIX@@h3._ST_ASH3_POLYFILL
(geojson STRING, _resolution DOUBLE)
RETURNS ARRAY
LANGUAGE JAVASCRIPT
IMMUTABLE
AS $$
    if (!GEOJSON || _RESOLUTION == null) {
        return [];
    }

    const resolution = Number(_RESOLUTION);
    if (resolution < 0 || resolution > 15) {
        return [];
    }

    function setup() {
        @@SF_LIBRARY_ASH3_POLYFILL@@
        polyfill = h3Lib.polyfill;
    }

    if (typeof(polyfill) === "undefined") {
        setup();
    }

    const featureGeometry = JSON.parse(GEOJSON)
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
            return [];
    }

    if (polygonCoordinates.length === 0) {
        return [];
    }

    let hexes = polygonCoordinates.reduce(
        (acc, coordinates) => acc.concat(polyfill(coordinates, resolution, true)),
        []
    ).filter(h => h != null);
    hexes = [...new Set(hexes)];
    return hexes;
$$;

CREATE OR REPLACE SECURE FUNCTION @@SF_PREFIX@@h3.ST_ASH3_POLYFILL
(geog GEOGRAPHY, resolution INT)
RETURNS ARRAY
IMMUTABLE
AS $$
    @@SF_PREFIX@@h3._ST_ASH3_POLYFILL(CAST(ST_ASGEOJSON(GEOG) AS STRING), CAST(RESOLUTION AS DOUBLE))
$$;