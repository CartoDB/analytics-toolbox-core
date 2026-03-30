----------------------------
-- Copyright (C) 2026 CARTO
----------------------------

CREATE OR REPLACE FUNCTION `@@BQ_DATASET@@.__GEOJSON_PARSE_FEATURES`
(geojson STRING)
RETURNS ARRAY<STRUCT<properties STRING, geom STRING>>
DETERMINISTIC
LANGUAGE js
AS """
    if (!geojson) return [];
    const obj = JSON.parse(geojson);
    let features;
    if (obj.type === 'FeatureCollection') {
        features = obj.features || [];
    } else if (obj.type === 'Feature') {
        features = [obj];
    } else {
        // Bare geometry
        return [{ properties: '{}', geom: geojson }];
    }
    return features.map(f => ({
        properties: JSON.stringify(f.properties || {}),
        geom: JSON.stringify(f.geometry)
    }));
""";
