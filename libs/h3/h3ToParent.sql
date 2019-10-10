CREATE OR REPLACE FUNCTION jslibs.h3.h3ToParent(h3Index STRING, resolution NUMERIC)
 RETURNS STRING
 LANGUAGE js AS
"""
return h3.h3ToParent(h3Index,resolution);
"""
OPTIONS (
  library=["gs://bigquery-jslibs/h3/latest/h3-js.umd.js"]
);