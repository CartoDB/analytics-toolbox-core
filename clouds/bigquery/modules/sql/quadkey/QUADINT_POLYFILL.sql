----------------------------
-- Copyright (C) 2021 CARTO
----------------------------

CREATE OR REPLACE FUNCTION `@@BQ_DATASET@@.__QUADINT_POLYFILL`
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
            quadints = quadints.concat(coreLib.quadkey.geojsonToQuadints(geom, {min_zoom: Number(resolution), max_zoom: Number(resolution)}));
        });
        quadints = Array.from(new Set(quadints));
    }
    else
    {
        quadints = coreLib.quadkey.geojsonToQuadints(pol, {min_zoom: Number(resolution), max_zoom: Number(resolution)});
    }
    return quadints.map(String);
""";

CREATE OR REPLACE FUNCTION `@@BQ_DATASET@@.QUADINT_POLYFILL`
(geog GEOGRAPHY, resolution INT64)
RETURNS ARRAY<INT64>
AS (
    `@@BQ_DATASET@@.__QUADINT_POLYFILL`(ST_ASGEOJSON(geog), resolution)
);