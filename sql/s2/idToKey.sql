CREATE OR REPLACE FUNCTION jslibs.s2.idToKey(key INT64)
  RETURNS STRING
  LANGUAGE js AS
"""
return S2.idToKey(key);
"""
OPTIONS (
  library=["gs://bigquery-jslibs/s2geometry.js"]
);
