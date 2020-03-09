CREATE OR REPLACE FUNCTION jslibs.turf.ST_BUFFER(geojson GEOGRAPHY, radius NUMERIC, units STRING, steps NUMERIC) AS (
  ST_GEOGFROMGEOJSON(jslibs.turf.buffer(ST_ASGEOJSON(geojson),radius,STRUCT(units,steps)))
);