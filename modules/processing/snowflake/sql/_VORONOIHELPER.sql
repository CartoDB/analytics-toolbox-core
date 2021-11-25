----------------------------
-- Copyright (C) 2021 CARTO
----------------------------


CREATE OR REPLACE FUNCTION _VORONOIHELPER
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

    @@SF_LIBRARY_CONTENT@@

    const options = {};
    options.bbox = BBOX;
    
    const featuresCollection = processingLib.featureCollection(GEOJSON.map(x => processingLib.feature(JSON.parse(x))));
    const voronoiPolygons = processingLib.voronoi(featuresCollection, options);
    
    const returnArray = [];

    if (TYPEOFVORONOI === 'poly') {
        voronoiPolygons.features.forEach( function(item) {
            returnArray.push(JSON.stringify(item.geometry));
        });
    }
    
    if (TYPEOFVORONOI === 'lines') {
        voronoiPolygons.features.forEach( function(item) {
            let lineFeature = processingLib.polygonToLine(item.geometry);
            returnArray.push(JSON.stringify(lineFeature.geometry));
        });
    }

    return returnArray;
$$;