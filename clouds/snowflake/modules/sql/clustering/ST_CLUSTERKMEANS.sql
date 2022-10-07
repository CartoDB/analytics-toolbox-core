----------------------------
-- Copyright (C) 2021 CARTO
----------------------------

CREATE OR REPLACE FUNCTION @@SF_SCHEMA@@._CLUSTERKMEANS
(geojsons ARRAY, numberOfClusters DOUBLE)
RETURNS ARRAY
LANGUAGE JAVASCRIPT
IMMUTABLE
AS $$
    if (!GEOJSONS || NUMBEROFCLUSTERS == null) {
        return [];
    }

    @@SF_LIBRARY_CLUSTERING@@

    const options = {};
    options.numberOfClusters = Number(NUMBEROFCLUSTERS);
    options.mutate = true;
    const featuresCollection = clusteringLib.featureCollection(GEOJSONS.map(x => clusteringLib.feature(JSON.parse(x))));
    clusteringLib.clustersKmeans(featuresCollection, options);
    const cluster = [];
    featuresCollection.features.forEach(function(item, index, array) {
        cluster.push({cluster: item.properties.cluster, geom: JSON.stringify(item.geometry)});
    });
    return cluster;
$$;

CREATE OR REPLACE SECURE FUNCTION @@SF_SCHEMA@@.ST_CLUSTERKMEANS
(geojsons ARRAY)
RETURNS ARRAY
IMMUTABLE
AS $$
    @@SF_SCHEMA@@._CLUSTERKMEANS(GEOJSONS, CAST(SQRT(ARRAY_SIZE(GEOJSONS)/2)::INT AS DOUBLE))
$$;

CREATE OR REPLACE SECURE FUNCTION @@SF_SCHEMA@@.ST_CLUSTERKMEANS
(geojsons ARRAY, numberOfClusters INT)
RETURNS ARRAY
IMMUTABLE
AS $$
    @@SF_SCHEMA@@._CLUSTERKMEANS(GEOJSONS, CAST(NUMBEROFCLUSTERS AS DOUBLE))
$$;
