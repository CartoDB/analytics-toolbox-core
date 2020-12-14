CREATE OR REPLACE FUNCTION jslibs.placekey.placekeyToH3(placekey STRING)
    RETURNS STRING
    DETERMINISTIC
    LANGUAGE js AS
"""
    return placekeyToH3(placekey);
"""
OPTIONS (
  library=["gs://bigquery-jslibs/h3-js.umd.js",
           "gs://bigquery-jslibs/h3-integer.js",
           "gs://bigquery-jslibs/placekey.js"]
);
