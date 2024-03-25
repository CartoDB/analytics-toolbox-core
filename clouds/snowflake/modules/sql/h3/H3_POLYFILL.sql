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
	    if (g.type === 'Polygon'|| g.type === 'MultiPolygon') {
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

    // TODO - I think this will always be one polygon? Does it get _HEMI_SPLIT?
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
    INDICIES.forEach(h3Index => {
	polygons.some(p => {
	    if (h3PolyfillLib.booleanContains(p, h3PolyfillLib.polygon([h3BoundaryLib.h3ToGeoBoundary(h3Index, true)]))) {
	        results.push(h3Index)	
	    }
	})	
    })
    return results
$$;

CREATE OR REPLACE FUNCTION @@SF_SCHEMA@@._H3_AVG_M_DIAMETER
(resolution DOUBLE)
RETURNS DOUBLE
LANGUAGE JAVASCRIPT
IMMUTABLE
AS $$
    return parseInt([
        1281.256011 * 2 * 1000,
        483.0568391 * 2 * 1000,
        182.5129565 * 2 * 1000,
        68.97922179 * 2 * 1000,
        26.07175968 * 2 * 1000,
        9.854090990 * 2 * 1000,
        3.724532667 * 2 * 1000,
        1.406475763 * 2 * 1000,
        0.531414010 * 2 * 1000,
        0.200786148 * 2 * 1000,
        0.075863783 * 2 * 1000,
        0.028663897 * 2 * 1000,
        0.010830188 * 2 * 1000,
        0.004092010 * 2 * 1000,
        0.001546100 * 2 * 1000,
        0.000584169 * 2 * 1000
    ][RESOLUTION])
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
	polygons.some(p => {
	    if (h3PolyfillLib.booleanIntersects(p, h3PolyfillLib.polygon([h3BoundaryLib.h3ToGeoBoundary(h3Index, true)]))) {
	        results.push(h3Index)	
	    }
	})	
    })
    return results
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
	WHEN MODE = 'intersects' THEN @@SF_SCHEMA@@._H3_POLYFILL_INTERSECTS_FILTER(H3_COVERAGE_STRINGS(TO_GEOGRAPHY(@@SF_SCHEMA@@._HEMI_SPLIT(CAST(ST_ASGEOJSON(GEOG) AS STRING))), RESOLUTION), CAST(ST_ASGEOJSON(GEOG) AS STRING))
	WHEN MODE = 'contains' THEN @@SF_SCHEMA@@._H3_POLYFILL_CONTAINS(CAST(ST_ASGEOJSON(GEOG) AS STRING), @@SF_SCHEMA@@.H3_POLYFILL(GEOG, RESOLUTION))
	ELSE []
    END
$$;
