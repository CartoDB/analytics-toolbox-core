----------------------------
-- Copyright (C) 2021 CARTO
----------------------------

CREATE OR REPLACE FUNCTION @@SF_PREFIX@@h3._ST_ASH3_POLYFILL
(geojson STRING, _resolution DOUBLE)
RETURNS ARRAY
LANGUAGE JAVASCRIPT
AS $$
    @@SF_LIBRARY_ash3_polyfill@@

    if (!GEOJSON || _RESOLUTION == null) {
        return [];
    }

    const resolution = Number(_RESOLUTION);
    if (resolution < 0 || resolution > 15) {
        return [];
    }

    const featureGeometry = JSON.parse(GEOJSON)
    if (!['Polygon', 'MultiPolygon'].includes(featureGeometry.type)) {
        return [];
    }

    const polygonCoordinates =  featureGeometry.type === 'MultiPolygon' ? featureGeometry.coordinates : [featureGeometry.coordinates];
    let hexes = polygonCoordinates.reduce(
        (acc, coordinates) => acc.concat(h3Lib.polyfill(coordinates, resolution, true)),
        []
    ).filter(h => h != null);
    hexes = [...new Set(hexes)];
    return hexes;
$$;

CREATE OR REPLACE SECURE FUNCTION @@SF_PREFIX@@h3.ST_ASH3_POLYFILL
(geog GEOGRAPHY, resolution INT)
RETURNS ARRAY
AS $$
    @@SF_PREFIX@@h3._ST_ASH3_POLYFILL(CAST(ST_ASGEOJSON(GEOG) AS STRING), CAST(RESOLUTION AS DOUBLE))
$$;