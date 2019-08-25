CREATE OR REPLACE FUNCTION jslibs.h3_3_5_0.h3Index(latitude FLOAT64, longitude FLOAT64, resolution NUMERIC)
  RETURNS STRING
  LANGUAGE js AS
"""
return h3.geoToH3(latitude, longitude, resolution);
"""
OPTIONS (
  library=["gs://bigquery-jslibs/h3/3.5.0/h3-js.umd.3.5.0.js"]
);