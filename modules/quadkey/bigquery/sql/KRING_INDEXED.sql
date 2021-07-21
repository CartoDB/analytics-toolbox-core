----------------------------
-- Copyright (C) 2021 CARTO
----------------------------

CREATE OR REPLACE FUNCTION `@@BQ_PREFIX@@quadkey.KRING_INDEXED(quadint INT64,
    distance INT64)
  RETURNS ARRAY<STRUCT<distance INT64,
  quadint ARRAY<INT64>>> DETERMINISTIC
  LANGUAGE js OPTIONS (library=["@@BQ_LIBRARY_BUCKET@@"]) AS R"""
if (quadint == null) {
        throw new Error('NULL argument passed to UDF');
    }
    if (distance == null) {
        distance = 1;
    }
    return Array.from(Array(parseInt(distance)).keys()).map(x => ({quadint:quadkeyLib.kring_hollow(quadint, x).map(String), distance:x}));
""";