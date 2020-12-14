CREATE OR REPLACE FUNCTION jslibs.s2.latLngToKey(latitude FLOAT64, longitude FLOAT64, level NUMERIC)
  RETURNS STRING
  DETERMINISTIC
  LANGUAGE js AS
"""
return S2.latLngToKey(latitude, longitude, level);
"""
OPTIONS (
  library=["gs://bigquery-jslibs/s2geometry.js"]
);
