CREATE OR REPLACE FUNCTION jslibs.placekey.geoToPlacekey(latitude FLOAT64, longitude FLOAT64)
    RETURNS STRING
    DETERMINISTIC
    LANGUAGE js AS
"""
    return geoToPlacekey(latitude, longitude);
"""
OPTIONS (
  library=["gs://bigquery-jslibs/h3-js.umd.js",
           "gs://bigquery-jslibs/h3-integer.js",
           "gs://bigquery-jslibs/placekey.js"]
);
