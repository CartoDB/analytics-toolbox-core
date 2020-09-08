CREATE OR REPLACE FUNCTION jslibs.s2.keyToId(key STRING)
  RETURNS INT64
  LANGUAGE js AS
"""
return S2.keyToId(key);
"""
OPTIONS (
  library=["gs://bigquery-jslibs/s2geometry.js"]
);
