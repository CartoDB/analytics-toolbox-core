CREATE OR REPLACE FUNCTION jslibs.h3.h3GetBaseCell(h3Index STRING)
 RETURNS NUMERIC
 LANGUAGE js AS
"""
return h3.h3GetBaseCell(h3Index);
"""
OPTIONS (
  library=["gs://bigquery-jslibs/h3-js.umd.js"]
);