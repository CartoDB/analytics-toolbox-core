CREATE OR REPLACE FUNCTION jslibs.s2.idToLat(key STRING)
  RETURNS FLOAT64
  DETERMINISTIC
  LANGUAGE js AS
"""
return S2.idToLatLng(key)["lat"];
"""
OPTIONS (
  library=["gs://bigquery-jslibs/s2geometry.js"]
);
