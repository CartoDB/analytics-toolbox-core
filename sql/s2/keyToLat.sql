CREATE OR REPLACE FUNCTION jslibs.s2.keyToLat(key STRING)
  RETURNS FLOAT64
  LANGUAGE js AS
"""
return S2.idToLatLng(key)["lat"];
"""
OPTIONS (
  library=["gs://bigquery-jslibs/s2geometry.js"]
);
