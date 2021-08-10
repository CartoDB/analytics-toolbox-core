----------------------------
-- Copyright (C) 2021 CARTO
----------------------------

CREATE OR REPLACE FUNCTION `@@BQ_PREFIX@@quadkey.__POLYFILL_FROMGEOJSON`
(geojson STRING, resolution INT64)
RETURNS ARRAY<INT64>
DETERMINISTIC
LANGUAGE js
OPTIONS (library=["@@BQ_LIBRARY_BUCKET@@"])
AS """
    if (!geojson || resolution == null) {
        throw new Error('NULL argument passed to UDF');
    }
    const pol = JSON.parse(geojson);
    let quadints = [];
    if (pol.type == 'GeometryCollection') {
        pol.geometries.forEach(function (geom) {
            quadints = quadints.concat(quadkeyLib.geojsonToQuadints(geom, {min_zoom: Number(resolution), max_zoom: Number(resolution)}));
        });
        quadints = Array.from(new Set(quadints));
    }
    else
    {
        quadints = quadkeyLib.geojsonToQuadints(pol, {min_zoom: Number(resolution), max_zoom: Number(resolution)});
    }
    return quadints.map(String);
""";

CREATE OR REPLACE FUNCTION `@@BQ_PREFIX@@quadkey.ST_ASQUADINT_POLYFILL`
(geog GEOGRAPHY, resolution INT64)
RETURNS ARRAY<INT64>
AS (
    `@@BQ_PREFIX@@quadkey.__POLYFILL_FROMGEOJSON`(ST_ASGEOJSON(geog), resolution)
);