----------------------------
-- Copyright (C) 2021 CARTO
----------------------------

CREATE OR REPLACE FUNCTION @@SF_SCHEMA@@._VORONOIHELPER
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

    @@SF_LIBRARY_PROCESSING@@

    const options = {};
    options.bbox = BBOX;

    const featuresCollection = processingLib.featureCollection(GEOJSON.map(x => processingLib.feature(JSON.parse(x))));

    // Truncate the point coordinates to 5 decimals, because having two very close distinct points
    // triggers a bug a in d3-voronoi ("Cannot read properties of null (reading 'circle')")
    // TODO: consider adding `mutate: true` to the options for performance (but user input will be altered)
    const truncatedFeatures = processingLib.truncate(featuresCollection, { precision: 5, coordinates: 2 });
    const voronoiPolygons = processingLib.voronoi(truncatedFeatures, options);

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
