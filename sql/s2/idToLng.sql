CREATE OR REPLACE FUNCTION jslibs.s2.idToLng(key STRING)
  RETURNS FLOAT64
  LANGUAGE js AS
"""
return S2.idToLatLng(key)["lng"];
"""
OPTIONS (
  library=["gs://bigquery-jslibs/s2geometry.js"]
);
