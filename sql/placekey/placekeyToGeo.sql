CREATE OR REPLACE FUNCTION jslibs.placekey.placekeyToGeo(placekey STRING)
    RETURNS STRING
    LANGUAGE js AS
"""
    return placekeyToGeo(placekey);
"""
OPTIONS (
  library=["gs://bigquery-jslibs/h3-js.umd.js",
           "gs://bigquery-jslibs/h3-integer.js",
           "gs://bigquery-jslibs/placekey.js"]
);
