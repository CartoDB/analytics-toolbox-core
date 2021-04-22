-----------------------------------------------------------------------
--
-- Copyright (C) 2021 CARTO
--
-----------------------------------------------------------------------

CREATE OR REPLACE FUNCTION `@@BQ_PROJECTID@@.@@BQ_DATASET_AGGREGATION@@.__CLUSTERKMEANS`
    (geojson STRING)
    RETURNS STRING
    DETERMINISTIC
    LANGUAGE js
    OPTIONS (library=["@@AGGREGATION_BQ_LIBRARY@@"])
AS """
    if (!geojson) {
        return null;
    }

    let clustered = turf.clustersKmeans(JSON.parse(geojson), {});
    return JSON.stringify(clustered.geometry);
""";

CREATE OR REPLACE FUNCTION `@@BQ_PROJECTID@@.@@BQ_DATASET_AGGREGATION@@.ST_CLUSTERKMEANS`
    (geog GEOGRAPHY)
AS (
    ST_GEOGFROMGEOJSON(`@@BQ_PROJECTID@@`.@@BQ_DATASET_AGGREGATION@@.__CLUSTERKMEANS(ST_ASGEOJSON(geog)))
);