----------------------------
-- Copyright (C) 2021 CARTO
----------------------------

CREATE OR REPLACE FUNCTION @@SF_SCHEMA@@._HEMI_SPLIT
(geojson STRING)
RETURNS STRING
LANGUAGE JAVASCRIPT
IMMUTABLE
AS $$

    let inputGeoJSON = JSON.parse(GEOJSON);

    @@SF_LIBRARY_H3_POLYFILL@@

    const westernHemisphere = h3PolyfillLib.polygon([[ [-180, 90], [0, 90], [0, -90], [-180, -90], [-180, 90]]]);
    const easternHemisphere = h3PolyfillLib.polygon([[ [0, 90], [180, 90], [180, -90], [0, -90], [0, 90] ]]);

    let polygons = [];

    if (inputGeoJSON.type == "GeometryCollection") {
	inputGeoJSON.geometries.forEach(g => {
	    if (g.type === 'Polygon' || g.type === 'MultiPolygon') {
	        polygons.push(g)	
	    }	
	});
    }
    else if (inputGeoJSON.type === 'Polygon' || inputGeoJSON.type === 'MultiPolygon') {
        polygons.push(inputGeoJSON)	
    }

    let intersections = [];

    let intersectAndPush = (hemisphere, poly) => {
        const intersection = h3PolyfillLib.intersect(poly, hemisphere);
	if (intersection) {
	    intersections.push(intersection);
	}
    };

    polygons.forEach(p => {
        intersectAndPush(westernHemisphere, p);
        intersectAndPush(easternHemisphere, p);
    })

    return JSON.stringify(h3PolyfillLib.geometryCollection(intersections.map(i => i.geometry)));
$$;

CREATE OR REPLACE FUNCTION @@SF_SCHEMA@@._H3_POLYFILL_CONTAINS
(geojson STRING, indicies ARRAY)
RETURNS ARRAY
LANGUAGE JAVASCRIPT
IMMUTABLE
AS $$
    let results = []
    let inputGeoJSON = JSON.parse(GEOJSON);

    @@SF_LIBRARY_H3_POLYFILL@@
    @@SF_LIBRARY_H3_BOUNDARY@@

    let polygons = [];
    let geometries = []

    if (inputGeoJSON.type == "GeometryCollection") {
        geometries = inputGeoJSON.geometries	
    }
    else {
	geometries = [inputGeoJSON]	
    }
    geometries.forEach(g => {
        if (g.type === 'Polygon') {
	    polygons.push(g)	
        }	
        else if (g.type === 'MultiPolygon') {
	    g.coordinates.forEach(ring => polygons.push({type: 'Feature', geometry: {type: 'Polygon', coordinates: ring}}))
        }
    });
    INDICIES.forEach(h3Index => {
	polygons.some(p => {
	    if (h3PolyfillLib.booleanContains(p, h3PolyfillLib.polygon([h3BoundaryLib.h3ToGeoBoundary(h3Index, true)]))) {
	        results.push(h3Index)	
	    }
	})	
    })
    return results
$$;

CREATE OR REPLACE SECURE FUNCTION @@SF_SCHEMA@@._H3_POLYFILL_INTERSECTS_FILTER
(h3Indicies ARRAY, geojson STRING)
RETURNS ARRAY
LANGUAGE JAVASCRIPT
IMMUTABLE
AS $$

    let results = []
    let inputGeoJSON = JSON.parse(GEOJSON);

    @@SF_LIBRARY_H3_POLYFILL@@
    @@SF_LIBRARY_H3_BOUNDARY@@

    let polygons = [];

    if (inputGeoJSON.type == "GeometryCollection") {
	inputGeoJSON.geometries.forEach(g => {
	    if (g.type === 'Polygon'|| g.type === 'MultiPolygon') {
	        polygons.push(g)	
	    }	
	});
    }
    else if (inputGeoJSON.type === 'Polygon' || inputGeoJSON.type === 'MultiPolygon') {
        polygons.push(inputGeoJSON)	
    }
    H3INDICIES.forEach(h3Index => {
	if (polygons.some(p => h3PolyfillLib.booleanIntersects(p, h3PolyfillLib.polygon([h3BoundaryLib.h3ToGeoBoundary(h3Index, true)])))) {
	    results.push(h3Index)
	}
    })
    return [...new Set(results)]
$$;


CREATE OR REPLACE FUNCTION @@SF_SCHEMA@@._CHECK_TOO_WIDE(geo GEOGRAPHY)
RETURNS BOOLEAN
AS
$$
    CASE
        WHEN ST_XMax(geo) < ST_XMin(geo) THEN
            -- Adjusts for crossing the antimeridian
            360 + ST_XMax(geo) - ST_XMin(geo) >= 180
        ELSE
            ST_XMax(geo) - ST_XMin(geo) >= 180
    END
$$;

CREATE OR REPLACE SECURE FUNCTION @@SF_SCHEMA@@.H3_POLYFILL
(geog GEOGRAPHY, resolution INT)
RETURNS ARRAY
IMMUTABLE
AS $$
    IFF(
        GEOG IS NOT NULL AND RESOLUTION BETWEEN 0 AND 15,
	COALESCE(H3_POLYGON_TO_CELLS_STRINGS(TO_GEOGRAPHY(@@SF_SCHEMA@@._HEMI_SPLIT(CAST(ST_ASGEOJSON(GEOG) AS STRING))), RESOLUTION), []),
	[]
    ) 
$$;

CREATE OR REPLACE SECURE FUNCTION @@SF_SCHEMA@@.H3_POLYFILL
(geog GEOGRAPHY, resolution INT, mode STRING)
RETURNS ARRAY
IMMUTABLE
AS $$
    CASE WHEN GEOG IS NULL OR RESOLUTION NOT BETWEEN 0 AND 15 THEN []
	WHEN MODE = 'center' THEN @@SF_SCHEMA@@.H3_POLYFILL(GEOG, RESOLUTION)
	WHEN MODE = 'intersects' THEN
	    CASE WHEN @@SF_SCHEMA@@._CHECK_TOO_WIDE(GEOG) THEN @@SF_SCHEMA@@._H3_POLYFILL_INTERSECTS_FILTER(H3_COVERAGE_STRINGS(TO_GEOGRAPHY(@@SF_SCHEMA@@._HEMI_SPLIT(CAST(ST_ASGEOJSON(GEOG) AS STRING))), RESOLUTION), CAST(ST_ASGEOJSON(GEOG) AS STRING))
	        ELSE H3_COVERAGE_STRINGS(@@SF_SCHEMA@@.ST_BUFFER(GEOG, CAST(0.00000001 AS DOUBLE)), RESOLUTION)
	    END
	WHEN MODE = 'contains' THEN @@SF_SCHEMA@@._H3_POLYFILL_CONTAINS(CAST(ST_ASGEOJSON(@@SF_SCHEMA@@.ST_BUFFER(GEOG, CAST(0.00000001 AS DOUBLE))) AS STRING), @@SF_SCHEMA@@.H3_POLYFILL(GEOG, RESOLUTION))
	ELSE []
    END
$$;
