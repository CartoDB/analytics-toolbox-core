--Convert a lat/lng point to a hexagon index at resolution 7
--https://github.com/uber/h3-js#module_h3.geoToH3
CREATE OR REPLACE FUNCTION jslibs.h3.h3Index(latitude FLOAT64, longitude FLOAT64, resolution NUMERIC)
  RETURNS STRING
  LANGUAGE js AS
"""
return h3.geoToH3(latitude, longitude, resolution);
"""
OPTIONS (
  library=["gs://bigquery-jslibs/h3/latest/h3-js.umd.js"]
);

--Get the center of the hexagon with an output of an array with LatitudeLongitude
CREATE OR REPLACE FUNCTION jslibs.h3.h3ToLatLng(h3Index STRING)
  RETURNS ARRAY<FLOAT64>
  LANGUAGE js AS
"""
return h3.h3ToGeo(h3Index);
"""
OPTIONS (library=["gs://bigquery-jslibs/h3/latest/h3-js.umd.js"]);

--Get the center of the hexagon as GEOMETRY POINT
CREATE OR REPLACE FUNCTION jslibs.h3.h3toGeo(h3Index STRING) AS (ST_GEOGPOINT(h3ToLatLng(h3Index)[OFFSET(1)],h3ToLatLng(h3Index)[OFFSET(0)]));
