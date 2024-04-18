--------------------------------
-- Copyright (C) 2021-2024 CARTO
--------------------------------

CREATE OR REPLACE FUNCTION `@@BQ_DATASET@@.__CLUSTERKMEANS`
(geojson ARRAY<STRING>, numberOfClusters INT64)
RETURNS ARRAY<STRUCT<cluster INT64, geom STRING>>
DETERMINISTIC
LANGUAGE js
OPTIONS (library = ["@@BQ_LIBRARY_BUCKET@@"])
AS """
    if (!geojson) {
        return null;
    }
    const options = {};
    if (numberOfClusters != null) {
        options.numberOfClusters = Number(numberOfClusters);
    } else {
        options.numberOfClusters = parseInt(Math.sqrt(geojson.length/2))
    }
    options.mutate = true;
    const featuresCollection = lib.clustering.featureCollection(lib.clustering.prioritizeDistinctSort(geojson).map(x => lib.clustering.feature(JSON.parse(x))));
    lib.clustering.clustersKmeans(featuresCollection, options);
    const cluster = [];
    featuresCollection.features.forEach(function(item, index, array) {
        cluster.push({cluster: item.properties.cluster, geom: JSON.stringify(item.geometry)});
    });
    return cluster;
""";

CREATE OR REPLACE FUNCTION `@@BQ_DATASET@@.ST_CLUSTERKMEANS`
(geog ARRAY<GEOGRAPHY>, numberOfClusters INT64)
RETURNS ARRAY<STRUCT<cluster INT64, geom GEOGRAPHY>>
AS ((
    WITH cluteredpoints AS (
        SELECT `@@BQ_DATASET@@.__CLUSTERKMEANS`(ARRAY_AGG(ST_ASGEOJSON(x)), numberofclusters) AS clustered_arr
        FROM UNNEST(geog) AS x
    )

    SELECT ARRAY_AGG(STRUCT(x.cluster AS cluster, ST_GEOGFROMGEOJSON(x.geom) AS geom))
    FROM cluteredpoints, UNNEST(clustered_arr) AS x
));
