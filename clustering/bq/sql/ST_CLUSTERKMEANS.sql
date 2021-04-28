-----------------------------------------------------------------------
--
-- Copyright (C) 2021 CARTO
--
-----------------------------------------------------------------------

CREATE OR REPLACE FUNCTION `@@BQ_PROJECTID@@.@@BQ_DATASET_CLUSTERING@@.__CLUSTERKMEANS`
    (geojson ARRAY<STRING>, numberOfClusters INT64)
    RETURNS STRING
    DETERMINISTIC
    LANGUAGE js
    OPTIONS (library=["@@CLUSTERING_BQ_LIBRARY@@"])
AS """
    if (!geojson) {
        return null;
    }
    let options = {};
    if(numberOfClusters != null)
    {
        options.numberOfClusters = Number(numberOfClusters);
    }
    const features = turf.featureCollection(geojson.map(x => turf.feature(JSON.parse(x))));
    let clustered = turf.clustersKmeans(features, options);
    return JSON.stringify(clustered);
    //return JSON.stringify(clustered.geometry);
""";

CREATE OR REPLACE FUNCTION `@@BQ_PROJECTID@@.@@BQ_DATASET_CLUSTERING@@.ST_CLUSTERKMEANS`
    (geog ARRAY<GEOGRAPHY>, numberOfClusters INT64)
AS ((
    SELECT ST_GEOGFROMGEOJSON(`@@BQ_PROJECTID@@`.@@BQ_DATASET_CLUSTERING@@.__CLUSTERKMEANS(ARRAY_AGG(ST_ASGEOJSON(x)), numberOfClusters)) FROM unnest(geog) x
));