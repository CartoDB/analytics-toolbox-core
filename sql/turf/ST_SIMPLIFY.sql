CREATE FUNCTION jslibs.turf.ST_SIMPLIFY(geojson GEOGRAPHY, tolerance NUMERIC) AS (
  ST_GEOGFROMGEOJSON(jslibs.turf.simplifyt(ST_ASGEOJSON(geojson), STRUCT(tolerance as tolerance, true as highQuality)))
);
