CREATE OR REPLACE FUNCTION jslibs.s2.latLngToId(latitude FLOAT64, longitude FLOAT64, level NUMERIC)
  RETURNS INT64
  LANGUAGE js AS
"""
return S2.latLngToId(latitude, longitude, level);
"""
OPTIONS (
  library=["gs://bigquery-jslibs/s2geometry.js"]
);
