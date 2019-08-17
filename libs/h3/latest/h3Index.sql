--Convert a lat/lng point to a hexagon index at resolution 7
--https://github.com/uber/h3-js#module_h3.geoToH3
CREATE OR REPLACE FUNCTION jslibs.h3.h3Index(latitude FLOAT64, longitude FLOAT64, resolution NUMERIC)
  RETURNS STRING
  LANGUAGE js AS
"""
return h3.geoToH3(latitude, longitude, resolution);
"""
OPTIONS (
  library=["gs://bigquery-jslibs/h3/latest/h3-js.umd.js"]
);