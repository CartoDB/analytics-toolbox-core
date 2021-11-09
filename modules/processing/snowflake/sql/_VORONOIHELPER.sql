----------------------------
-- Copyright (C) 2021 CARTO
----------------------------


CREATE OR REPLACE FUNCTION @@SF_PREFIX@@processing._VORONOIHELPER
(geojson ARRAY, bbox ARRAY, typeOfVoronoi STRING)
RETURNS ARRAY
LANGUAGE JAVASCRIPT
AS $$
    if (!GEOJSON || !BBOX) {
        return [];
    }
    
    if (BBOX != null && BBOX.length != 4) {
        throw new Error('Incorrect bounding box passed to UDF. It should contain the BBOX extends, i.e., [xmin, ymin, xmax, ymax]');
    }

    function setup() {
        @@SF_LIBRARY_CONTENT@@
        processingLibGlobal = processingLib;
    }

    if (typeof(processingLibGlobal) === "undefined") {
        setup();
    }

    const options = {};
    options.bbox = BBOX;
    
    const featuresCollection = processingLibGlobal.featureCollection(GEOJSON.map(x => processingLibGlobal.feature(JSON.parse(x))));
    const voronoiPolygons = processingLibGlobal.voronoi(featuresCollection, options);
    
    const returnArray = [];

    if (TYPEOFVORONOI === 'poly') {
        voronoiPolygons.features.forEach( function(item) {
            returnArray.push(JSON.stringify(item.geometry));
        });
    }
    
    if (TYPEOFVORONOI === 'lines') {
        voronoiPolygons.features.forEach( function(item) {
            let lineFeature = processingLibGlobal.polygonToLine(item.geometry);
            returnArray.push(JSON.stringify(lineFeature.geometry));
        });
    }

    return returnArray;
$$;