CREATE OR REPLACE FUNCTION jslibs.h3.geoToH3(latitude FLOAT64, longitude FLOAT64, resolution NUMERIC)
  RETURNS STRING
  DETERMINISTIC
  LANGUAGE js AS
"""
return h3.geoToH3(latitude, longitude, resolution);
"""
OPTIONS (
  library=["gs://bigquery-jslibs/h3-js.umd.js"]
);