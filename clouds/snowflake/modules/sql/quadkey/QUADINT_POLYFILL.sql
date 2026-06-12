----------------------------
-- Copyright (C) 2021 CARTO
----------------------------

CREATE OR REPLACE FUNCTION @@SF_SCHEMA@@._QUADINT_POLYFILL
(geojson STRING, resolution DOUBLE)
RETURNS ARRAY
LANGUAGE JAVASCRIPT
IMMUTABLE
AS $$
    if (!GEOJSON || RESOLUTION == null) {
        throw new Error('NULL argument passed to UDF');
    }

    @@SF_LIBRARY_QUADKEY@@

    const pol = JSON.parse(GEOJSON);
    let quadints = [];
    if (pol.type == 'GeometryCollection') {
        pol.geometries.forEach(function (geom) {
            quadints = quadints.concat(quadkeyLib.geojsonToQuadints(geom, {min_zoom: RESOLUTION, max_zoom: RESOLUTION}));
        });
        quadints = Array.from(new Set(quadints));
    }
    else
    {
        quadints = quadkeyLib.geojsonToQuadints(pol, {min_zoom: RESOLUTION, max_zoom: RESOLUTION});
    }
    return quadints.map(String);
$$;

CREATE OR REPLACE SECURE FUNCTION @@SF_SCHEMA@@.QUADINT_POLYFILL
(geo GEOGRAPHY, resolution INT)
RETURNS ARRAY
IMMUTABLE
AS $$
    @@SF_SCHEMA@@._QUADINT_POLYFILL(CAST(ST_ASGEOJSON(GEO) AS STRING),CAST(RESOLUTION AS DOUBLE))
$$;
