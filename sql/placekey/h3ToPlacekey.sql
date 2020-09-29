CREATE OR REPLACE FUNCTION jslibs.placekey.h3ToPlacekey(h3Index STRING)
    RETURNS STRING
    LANGUAGE js AS
"""
    return h3ToPlacekey(h3Index);
"""
OPTIONS (
  library=["gs://bigquery-jslibs/h3-js.umd.js",
           "gs://bigquery-jslibs/h3-integer.js",
           "gs://bigquery-jslibs/placekey.js"]
);
