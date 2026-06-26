----------------------------
-- Copyright (C) 2021 CARTO
----------------------------

CREATE OR REPLACE FUNCTION `@@BQ_DATASET@@.__ENVELOPE`
(geojson ARRAY<STRING>)
RETURNS STRING
DETERMINISTIC
LANGUAGE js
OPTIONS (
    library = ["@@BQ_LIBRARY_ACCESSORS_BUCKET@@"]
)
AS """
    if (!geojson) {
        return null;
    }

    const featuresCollection = accessorsLib.featureCollection(geojson.map(x => accessorsLib.feature(JSON.parse(x))));
    const enveloped = accessorsLib.envelope(featuresCollection);
    return JSON.stringify(enveloped.geometry);
""";

CREATE OR REPLACE FUNCTION `@@BQ_DATASET@@.ST_ENVELOPE`
(geog ARRAY<GEOGRAPHY>)
RETURNS GEOGRAPHY
AS ((
    -- IGNORE NULLS so NULL geographies are skipped instead of producing an
    -- invalid GeoJSON feature that breaks the envelope computation; an
    -- all-NULL array collapses to NULL.
    SELECT ST_GEOGFROMGEOJSON(`@@BQ_DATASET@@.__ENVELOPE`(ARRAY_AGG(ST_ASGEOJSON(x) IGNORE NULLS)))
    FROM UNNEST(geog) AS x
));
