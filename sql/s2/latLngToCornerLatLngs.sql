CREATE OR REPLACE FUNCTION jslibs.s2.latLngToCornerLatLngs(latitude FLOAT64, longitude FLOAT64, level NUMERIC) RETURNS STRING LANGUAGE js
OPTIONS (library=["gs://bigquery-jslibs/s2geometry.js"]) AS """
var cornerLatLng = S2.S2Cell.FromLatLng({ lat: latitude, lng: longitude }, level).getCornerLatLngs();
var geojson = {
    "type": "Polygon",
    "coordinates": [[
[cornerLatLng[0]['lat'],cornerLatLng[0]['lng']],
[cornerLatLng[1]['lat'],cornerLatLng[1]['lng']],
[cornerLatLng[2]['lat'],cornerLatLng[2]['lng']],
[cornerLatLng[3]['lat'],cornerLatLng[3]['lng']],
[cornerLatLng[0]['lat'],cornerLatLng[0]['lng']]
]]
};

return JSON.stringify(geojson);
""";
