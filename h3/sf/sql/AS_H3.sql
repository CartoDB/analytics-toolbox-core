-----------------------------------------------------------------------
--
-- Copyright (C) 2021 CARTO
--
-----------------------------------------------------------------------

CREATE OR REPLACE FUNCTION @@SF_DATABASEID@@.@@SF_SCHEMA_H3@@._LONGLAT_ASH3(longitude DOUBLE, latitude DOUBLE, resolution DOUBLE)
    RETURNS STRING
    LANGUAGE JAVASCRIPT
AS $$
    @@LIBRARY_FILE_CONTENT@@

    if (LONGITUDE == null || LATITUDE == null || RESOLUTION == null) {
        return null;
    }
    const index = h3.geoToH3(Number(LATITUDE), Number(LONGITUDE), Number(RESOLUTION));
    if (index) {
        return '0x' + index;
    }
    return null;
$$;

CREATE OR REPLACE FUNCTION @@SF_DATABASEID@@.@@SF_SCHEMA_H3@@.LONGLAT_ASH3(longitude DOUBLE, latitude DOUBLE, resolution INT)
RETURNS BIGINT
AS $$
    @@SF_DATABASEID@@.@@SF_SCHEMA_H3@@.H3_FROMHEX(@@SF_DATABASEID@@.@@SF_SCHEMA_H3@@._LONGLAT_ASH3(LONGITUDE, LATITUDE, CAST(RESOLUTION AS DOUBLE)))
$$;

CREATE OR REPLACE FUNCTION @@SF_DATABASEID@@.@@SF_SCHEMA_H3@@.ST_ASH3(geog GEOGRAPHY, resolution INT)
    RETURNS BIGINT
AS $$
    IFF(ST_NPOINTS(geog) = 1, 
        @@SF_DATABASEID@@.@@SF_SCHEMA_H3@@.LONGLAT_ASH3(ST_X(GEOG), ST_Y(GEOG), CAST(RESOLUTION AS DOUBLE)),
        null)
$$;

CREATE OR REPLACE FUNCTION @@SF_DATABASEID@@.@@SF_SCHEMA_H3@@._ST_ASH3_POLYFILL(geojson STRING, _resolution DOUBLE)
    RETURNS ARRAY
    LANGUAGE JAVASCRIPT
AS $$
    @@LIBRARY_FILE_CONTENT@@

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
        (acc, coordinates) => acc.concat(h3.polyfill(coordinates, resolution, true)),
        []
    ).filter(h => h != null);
    hexes = [...new Set(hexes)];

    const ids = hexes.map(h => '0x' + h);
    return ids;
$$;

CREATE OR REPLACE FUNCTION @@SF_DATABASEID@@.@@SF_SCHEMA_H3@@.ST_ASH3_POLYFILL(geog GEOGRAPHY, resolution INT)
    RETURNS ARRAY
AS $$
    @@SF_DATABASEID@@.@@SF_SCHEMA_H3@@._ST_ASH3_POLYFILL(CAST(ST_ASGEOJSON(GEOG) AS STRING), CAST(RESOLUTION AS DOUBLE))
$$;