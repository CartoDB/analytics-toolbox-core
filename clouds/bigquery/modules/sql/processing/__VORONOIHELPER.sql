----------------------------
-- Copyright (C) 2021 CARTO
----------------------------

CREATE OR REPLACE FUNCTION `@@BQ_DATASET@@.__VORONOIHELPER`
(geojson ARRAY<STRING>, bbox ARRAY<FLOAT64>, typeOfVoronoi STRING)
RETURNS ARRAY<STRING>
DETERMINISTIC
LANGUAGE js
OPTIONS (
    library = ["@@BQ_LIBRARY_PROCESSING_BUCKET@@"]
)
AS """
    if (!geojson) {
        return null;
    }

    if (bbox != null && bbox.length != 4) {
        throw new Error('Incorrect bounding box passed to UDF. It should contain the bbox extends, i.e., [xmin, ymin, xmax, ymax]');
    }

    const options = {};

    // If the bbox parameter is not included, turf.js will use a default [-180,-85,180,-85] bbox
    if (bbox != null) {
        options.bbox = bbox;
    }

    const featuresCollection = processingLib.featureCollection(geojson.map(x => processingLib.feature(JSON.parse(x))));
    const voronoiPolygons = processingLib.voronoi(featuresCollection, options);

    const returnArray = [];

    if (typeOfVoronoi === 'poly') {
        voronoiPolygons.features.forEach( function(item) {
            returnArray.push(JSON.stringify(item.geometry));
        });
    }

    if (typeOfVoronoi === 'lines') {
        voronoiPolygons.features.forEach( function(item) {
            let lineFeature = processingLib.polygonToLine(item.geometry);
            returnArray.push(JSON.stringify(lineFeature.geometry));
        });
    }

    return returnArray;
""";
