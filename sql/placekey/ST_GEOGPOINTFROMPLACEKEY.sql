CREATE OR REPLACE FUNCTION jslibs.placekey.ST_GEOGPOINTFROMPLACEKEY(placekey STRING) AS (   
    ST_GEOGPOINT(
        CAST(split(jslibs.placekey.placekeyToGeo(placekey),",")[OFFSET (1)] AS FLOAT64),
        CAST(split(jslibs.placekey.placekeyToGeo(placekey),",")[OFFSET (0)] AS FLOAT64))
);
