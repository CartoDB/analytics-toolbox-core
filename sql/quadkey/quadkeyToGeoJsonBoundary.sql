CREATE OR REPLACE FUNCTION jslibs.quadkey.quadkeyToGeoJsonBoundary(quadkey STRING)
  RETURNS STRING
  LANGUAGE js AS
"""
var b= bbox(quadkey);  
var geojson = {
    "type": "Polygon", 
    "coordinates": [[
    	[b.min.lng,b.min.lat],
    	[b.min.lng,b.max.lat],
    	[b.max.lng,b.max.lat],
    	[b.max.lng,b.min.lat],
    	[b.min.lng,b.min.lat]
    ]]
}

return JSON.stringify(geojson);


"""
OPTIONS (
  library=["gs://bigquery-jslibs/quadkey.js"]
);
