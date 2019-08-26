CREATE OR REPLACE FUNCTION jslibs.h3.uncompact(compactedSet ARRAY, resolution NUMERIC)
 RETURNS ARRAY<STRING>
 LANGUAGE js AS
"""
return h3.uncompact(compactedSet,resolution);
"""
OPTIONS (
  library=["gs://bigquery-jslibs/h3/latest/h3-js.umd.js"]
);