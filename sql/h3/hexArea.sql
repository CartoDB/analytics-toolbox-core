CREATE OR REPLACE FUNCTION jslibs.h3.hexArea(res NUMERIC,unit STRING)
 RETURNS NUMERIC
 LANGUAGE js AS
"""
return h3.hexArea(res,unit);
"""
OPTIONS (
  library=["gs://bigquery-jslibs/h3-js.umd.js"]
);