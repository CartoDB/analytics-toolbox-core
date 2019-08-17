CREATE OR REPLACE FUNCTION jslibs.h3_3_5_0.h3Index(latitude FLOAT64, longitude FLOAT64, resolution NUMERIC)
  RETURNS STRING
  LANGUAGE js AS
"""
return h3.geoToH3(latitude, longitude, resolution);
"""
OPTIONS (
  library=["gs://bigquery-jslibs/turf/5.1.6/turf.min.5.1.6.js"]
);