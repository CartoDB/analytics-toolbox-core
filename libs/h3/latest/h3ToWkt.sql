--Get the center of the hexagon with an output of an array with LatitudeLongitude
CREATE OR REPLACE FUNCTION jslibs.h3.h3ToWkt(h3Index STRING)
  RETURNS STRING
  LANGUAGE js AS
"""
var p = h3.h3ToGeo(h3Index);
return "POINT("+p[1]+" "+p[0]+")";
"""
OPTIONS (library=["gs://bigquery-jslibs/h3/latest/h3-js.umd.js"]);