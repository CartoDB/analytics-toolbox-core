----------------------------
-- Copyright (C) 2021 CARTO
----------------------------

CREATE OR REPLACE FUNCTION _QUADBIN_POLYFILL
(geojson STRING, resolution DOUBLE)
RETURNS STRING
LANGUAGE JAVASCRIPT
IMMUTABLE
AS $$
    if (!GEOJSON || RESOLUTION == null) {
        throw new Error('NULL argument passed to UDF');
    }

    @@SF_LIBRARY_CONTENT@@

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

CREATE OR REPLACE SECURE FUNCTION QUADBIN_POLYFILL
(geo GEOGRAPHY, resolution INT)
RETURNS ARRAY
IMMUTABLE
AS $$
    TO_ARRAY(PARSE_JSON(_QUADBIN_POLYFILL(CAST(ST_ASGEOJSON(GEO) AS STRING),CAST(RESOLUTION AS DOUBLE))))
$$;