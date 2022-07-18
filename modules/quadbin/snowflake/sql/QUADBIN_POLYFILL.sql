----------------------------
-- Copyright (C) 2021 CARTO
----------------------------

-- The function returns a STRING for two main issues related with Snowflake limitations
-- 1. Snowflake has a native support of BigInt numbers, however, if the UDF
-- returns this data type the next Snowflake internal error is raised:
-- SQL execution internal error: Processing aborted due to error 300010:3321206824
-- 2. If the UDF returns the hex codification of the quadbin to be parsed in a SQL
-- higher level by using the _QUADBIN_STRING_TOINT UDF a non-correlated query can be produced.

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
    let stringQuadbins = '[';
    quadbins.forEach(x => {stringQuadbins += x + ','});

    return stringQuadbins.slice(0, -1) + ']';
$$;

CREATE OR REPLACE SECURE FUNCTION QUADBIN_POLYFILL
(geo GEOGRAPHY, resolution INT)
RETURNS ARRAY
IMMUTABLE
AS $$
    TO_ARRAY(PARSE_JSON(_QUADBIN_POLYFILL(CAST(ST_ASGEOJSON(GEO) AS STRING),CAST(RESOLUTION AS DOUBLE))))
$$;