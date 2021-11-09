----------------------------
-- Copyright (C) 2021 CARTO
----------------------------

CREATE OR REPLACE FUNCTION @@SF_PREFIX@@quadkey._POLYFILL_FROMGEOJSON
(geojson STRING, resolution DOUBLE)
RETURNS ARRAY
LANGUAGE JAVASCRIPT
IMMUTABLE
AS $$
    if (!GEOJSON || RESOLUTION == null) {
        throw new Error('NULL argument passed to UDF');
    }

   function setup() {
        @@SF_LIBRARY_CONTENT@@
        quadkeyLibGlobal = quadkeyLib;
    }

    if (typeof(quadkeyLibGlobal) === "undefined") {
        setup();
    }

    const pol = JSON.parse(GEOJSON);
    let quadints = [];
    if (pol.type == 'GeometryCollection') {
        pol.geometries.forEach(function (geom) {
            quadints = quadints.concat(quadkeyLibGlobal.geojsonToQuadints(geom, {min_zoom: RESOLUTION, max_zoom: RESOLUTION}));
        });
        quadints = Array.from(new Set(quadints));
    }
    else
    {
        quadints = quadkeyLibGlobal.geojsonToQuadints(pol, {min_zoom: RESOLUTION, max_zoom: RESOLUTION});
    }
    return quadints.map(String);
$$;

CREATE OR REPLACE SECURE FUNCTION @@SF_PREFIX@@quadkey.ST_ASQUADINT_POLYFILL
(geo GEOGRAPHY, resolution INT)
RETURNS ARRAY
IMMUTABLE
AS $$
    @@SF_PREFIX@@quadkey._POLYFILL_FROMGEOJSON(CAST(ST_ASGEOJSON(GEO) AS STRING),CAST(RESOLUTION AS DOUBLE))
$$;