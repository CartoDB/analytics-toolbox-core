----------------------------
-- Copyright (C) 2021 CARTO
----------------------------

CREATE OR REPLACE FUNCTION `@@BQ_PREFIX@@h3.KRING_INDEXED_COORDS`
(idx STRING, distance INT64)
RETURNS ARRAY<STRUCT<idx STRING, i INT64, j INT64>> DETERMINISTIC LANGUAGE js
OPTIONS (library=["gs://bqcartodev/fbaptiste_h3/index.js"]) AS R"""
if (!idx || distance == null || distance < 0) {
        return null;
    }
    if (!h3Lib.h3IsValid(idx)) {
        return null;
    }

    euclidian_distance = function(x, localIjA, origin, destination) {
     const localIjB = h3Lib.experimentalH3ToLocalIj(origin,destination);
      return {idx:destination, i:localIjA.i-localIjB.i,j:localIjA.j-localIjB.j};
    }

    return Array.from(Array(parseInt(distance)+1).keys()).map(x => h3Lib.hexRing(idx, x).map(destination => (euclidian_distance(x, h3Lib.experimentalH3ToLocalIj(idx, idx), idx, destination)))).flat();
""";