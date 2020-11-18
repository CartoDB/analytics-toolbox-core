CREATE OR REPLACE FUNCTION jslibs.h3.edgeLength(res NUMERIC,unit STRING)
 RETURNS NUMERIC
 DETERMINISTIC
 LANGUAGE js AS
"""
return h3.edgeLength(res,unit);
"""
OPTIONS (
  library=["gs://bigquery-jslibs/h3-js.umd.js"]
);