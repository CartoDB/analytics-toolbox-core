CREATE OR REPLACE FUNCTION jslibs.h3.numHexagons(res NUMERIC)
 RETURNS NUMERIC
 DETERMINISTIC
 LANGUAGE js AS
"""
return h3.numHexagons(res);
"""
OPTIONS (
  library=["gs://bigquery-jslibs/h3-js.umd.js"]
);