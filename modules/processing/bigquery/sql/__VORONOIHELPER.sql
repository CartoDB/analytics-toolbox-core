----------------------------
-- Copyright (C) 2021 CARTO
----------------------------

CREATE OR REPLACE FUNCTION `@@BQ_PREFIX@@processing.__VORONOIHELPER`
(geojson ARRAY<STRING>, bbox ARRAY<FLOAT64>, typeOfVoronoi STRING)
RETURNS ARRAY<STRING>
DETERMINISTIC
LANGUAGE js
OPTIONS (library=["@@BQ_LIBRARY_BUCKET@@"])
AS """
    if (!geojson) {
        return null;
    }
    
    if (bbox != null && bbox.length != 4) {
        throw new Error('Incorrect bounding box passed to UDF. It should contain the bbox extends, i.e., [xmin, ymin, xmax, ymax]');
    }

    let options = {};

    // If the bbox parameter is not included, turf.js will use a default [-180,-85,180,-85] bbox 
    if(bbox != null) {
        options.bbox = bbox;
    }

    let featuresCollection = lib.featureCollection(geojson.map(x => lib.feature(JSON.parse(x))));
    let voronoiPolygons = lib.voronoi(featuresCollection, options);
    
    let returnArray = [];

    if (typeOfVoronoi === 'poly') {
        voronoiPolygons.features.forEach( function(item) {
            returnArray.push(JSON.stringify(item.geometry));
        });
    }
    
    if (typeOfVoronoi === 'lines') {
        voronoiPolygons.features.forEach( function(item) {
            let lineFeature = lib.polygonToLine(item.geometry);
            returnArray.push(JSON.stringify(lineFeature.geometry));
        });
    }

    return returnArray;
""";
