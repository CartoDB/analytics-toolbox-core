-----------------------------------------------------------------------
--
-- Copyright (C) 2021 CARTO
--
-----------------------------------------------------------------------

CREATE OR REPLACE FUNCTION `@@BQ_PROJECTID@@.@@BQ_DATASET_PROCESSING@@.__VORONOIHELPER`
    (geojson ARRAY<STRING>, bbox ARRAY<FLOAT64>, typeOfVoronoi STRING)
    RETURNS ARRAY<STRING>
    DETERMINISTIC
    LANGUAGE js
    OPTIONS (library=["@@PROCESSING_BQ_LIBRARY@@"])
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

    let featuresCollection = turf.featureCollection(geojson.map(x => turf.feature(JSON.parse(x))));
    let voronoiPolygons = turf.voronoi(featuresCollection, options);
    
    let returnArray = [];

    if (typeOfVoronoi === 'poly') {
        voronoiPolygons.features.forEach( function(item) {
            returnArray.push(JSON.stringify(item.geometry));
        });
    }
    
    if (typeOfVoronoi === 'lines') {
        voronoiPolygons.features.forEach( function(item) {
            let lineFeature = turf.polygonToLine(item.geometry);
            returnArray.push(JSON.stringify(lineFeature.geometry));
        });
    }

    return returnArray;
    
""";

CREATE OR REPLACE FUNCTION `@@BQ_PROJECTID@@.@@BQ_DATASET_PROCESSING@@.__VORONOIGENERIC`
    (points ARRAY<GEOGRAPHY>, bbox ARRAY<FLOAT64>, typeOfVoronoi STRING)
    RETURNS ARRAY<GEOGRAPHY>
AS (
   (
       WITH geojsonPoints AS 
       (
           SELECT ARRAY_AGG(ST_ASGEOJSON(p)) AS arrayPoints
           FROM UNNEST(points) AS p
       ),
       geojsonResult AS
       (
           SELECT `@@BQ_PROJECTID@@`.@@BQ_DATASET_PROCESSING@@.__VORONOIHELPER(arrayPoints, bbox, typeOfVoronoi) AS features
           FROM geojsonPoints
       )
   
       SELECT ARRAY(SELECT ST_GEOGFROMGEOJSON(unnestedFeatures) FROM geojsonResult, UNNEST(features) as unnestedFeatures)
   )   
);