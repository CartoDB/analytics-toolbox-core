--------------------------------
-- Copyright (C) 2021-2024 CARTO
--------------------------------

CREATE OR REPLACE FUNCTION @@SF_SCHEMA@@._HAS_POLYGON_JS
(geojson STRING)
RETURNS BOOLEAN
LANGUAGE JAVASCRIPT
IMMUTABLE
AS $$
    let inputGeoJSON = JSON.parse(GEOJSON);
    let geometries = inputGeoJSON.geometries ? inputGeoJSON.geometries : [inputGeoJSON] // geometrycollection or regular feature geometry
    for (let g of geometries) {
        if (g.type === 'Polygon' || g.type === 'MultiPolygon') {
	    return true
        }	
    }
    return false
$$;

CREATE OR REPLACE FUNCTION @@SF_SCHEMA@@._HAS_POLYGON
(geog GEOGRAPHY)
RETURNS BOOLEAN
LANGUAGE SQL
IMMUTABLE
AS $$
	@@SF_SCHEMA@@._HAS_POLYGON_JS(CAST(ST_ASGEOJSON(GEOG) AS STRING))
$$;

CREATE OR REPLACE FUNCTION @@SF_SCHEMA@@._FILTER_GEOG_JS
(geojson STRING)
RETURNS STRING
LANGUAGE JAVASCRIPT
IMMUTABLE
AS $$
    // remove non-polygons and split polygons >= 180 degrees
    // output is a always MULTIPOLYGON

    let inputGeoJSON = JSON.parse(GEOJSON);

    @@SF_LIBRARY_H3_POLYFILL@@

    const westernHemisphere = h3PolyfillLib.polygon([[ [-180, 90], [0, 90], [0, -90], [-180, -90], [-180, 90]]]);
    const easternHemisphere = h3PolyfillLib.polygon([[ [0, 90], [180, 90], [180, -90], [0, -90], [0, 90] ]]);

    let polygons = [];
    let geometries = inputGeoJSON.geometries ? inputGeoJSON.geometries : [inputGeoJSON]

    geometries.forEach(g => {
        if (g.type === 'Polygon') {
	    polygons.push({type: 'Feature', geometry: g})	
        }	
        else if (g.type === 'MultiPolygon') {
	    g.coordinates.forEach(ring => polygons.push({type: 'Feature', geometry: {type: 'Polygon', coordinates: ring}}))
        }
    });


    let intersections = [];

    let intersectAndPush = (hemisphere, poly) => {
        const intersection = h3PolyfillLib.intersect(poly, hemisphere);
	if (intersection) {
            if (intersection.geometry.type === 'Polygon') {
	        intersections.push(intersection);
            }	
            else if (intersection.geometry.type === 'MultiPolygon') {
	        intersection.geometry.coordinates.forEach(ring => intersections.push({type: 'Feature', geometry: {type: 'Polygon', coordinates: ring}}))
            }
	}
    };

    polygons.forEach(p => {
        intersectAndPush(westernHemisphere, p);
        intersectAndPush(easternHemisphere, p);
    })

    return JSON.stringify(h3PolyfillLib.multiPolygon(intersections.map(i => i.geometry.coordinates)).geometry)
$$;

CREATE OR REPLACE FUNCTION @@SF_SCHEMA@@._FILTER_GEOG
(geog GEOGRAPHY)
RETURNS GEOGRAPHY
LANGUAGE SQL
IMMUTABLE
AS $$
	TO_GEOGRAPHY(@@SF_SCHEMA@@._FILTER_GEOG_JS(CAST(ST_ASGEOJSON(GEOG) AS STRING)))
$$;

CREATE OR REPLACE FUNCTION @@SF_SCHEMA@@._H3_POLYFILL_CONTAINS
(geojson STRING, indexes ARRAY)
RETURNS ARRAY
LANGUAGE JAVASCRIPT
IMMUTABLE
AS $$
    let results = []
    let inputGeoJSON = JSON.parse(GEOJSON);

    @@SF_LIBRARY_H3_POLYFILL@@

    // @@SF_SCHEMA@@.ST_BUFFER demotes MULTIPOLYGONs to POLYGON if it only has one ring. So we check again here.
    let polygons = inputGeoJSON.type === 'MultiPolygon' ? inputGeoJSON.coordinates.map(ring => h3PolyfillLib.polygon(ring)) : [h3PolyfillLib.polygon(inputGeoJSON.coordinates)]


    INDEXES.forEach(h3Index => {
	polygons.some(p => {
	    if (h3PolyfillLib.booleanContains(p, h3PolyfillLib.polygon([h3PolyfillLib.h3ToGeoBoundary(h3Index, true)]))) {
	        results.push(h3Index)	
	    }
	})	
    })
    return results
$$;

CREATE OR REPLACE SECURE FUNCTION @@SF_SCHEMA@@._H3_POLYFILL_INTERSECTS_FILTER
(h3Indexes ARRAY, geojson STRING)
RETURNS ARRAY
LANGUAGE JAVASCRIPT
IMMUTABLE
AS $$

    let results = []
    let inputGeoJSON = JSON.parse(GEOJSON);

    @@SF_LIBRARY_H3_POLYFILL@@

    // @@SF_SCHEMA@@.ST_BUFFER demotes MULTIPOLYGONs to POLYGON if it only has one ring. So we check again here.
    let polygons = inputGeoJSON.type === 'MultiPolygon' ? inputGeoJSON.coordinates.map(ring => h3PolyfillLib.polygon(ring)) : [h3PolyfillLib.polygon(inputGeoJSON.coordinates)]

    H3INDEXES.forEach(h3Index => {
	if (polygons.some(p => h3PolyfillLib.booleanIntersects(p, h3PolyfillLib.polygon([h3PolyfillLib.h3ToGeoBoundary(h3Index, true)])))) {
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
        GEOG IS NOT NULL AND RESOLUTION >= 0 AND RESOLUTION <= 15 AND @@SF_SCHEMA@@._HAS_POLYGON(GEOG),
	COALESCE(H3_POLYGON_TO_CELLS_STRINGS(@@SF_SCHEMA@@._FILTER_GEOG(GEOG), RESOLUTION), []),
	[]
    ) 
$$;

CREATE OR REPLACE SECURE FUNCTION @@SF_SCHEMA@@.H3_POLYFILL
(geog GEOGRAPHY, resolution INT, mode STRING)
RETURNS ARRAY
IMMUTABLE
AS $$
    CASE WHEN GEOG IS NULL OR RESOLUTION < 0 OR RESOLUTION > 15 OR NOT @@SF_SCHEMA@@._HAS_POLYGON(GEOG) THEN []
	WHEN MODE = 'center' THEN @@SF_SCHEMA@@.H3_POLYFILL(GEOG, RESOLUTION)
	WHEN MODE = 'intersects' THEN
	    CASE WHEN @@SF_SCHEMA@@._CHECK_TOO_WIDE(GEOG) THEN @@SF_SCHEMA@@._H3_POLYFILL_INTERSECTS_FILTER(H3_COVERAGE_STRINGS(@@SF_SCHEMA@@._FILTER_GEOG(GEOG), RESOLUTION), CAST(ST_ASGEOJSON(GEOG) AS STRING))
	        ELSE H3_COVERAGE_STRINGS(@@SF_SCHEMA@@.ST_BUFFER(@@SF_SCHEMA@@._FILTER_GEOG(GEOG), CAST(0.00000001 AS DOUBLE)), RESOLUTION)
	    END
	WHEN MODE = 'contains' THEN @@SF_SCHEMA@@._H3_POLYFILL_CONTAINS(CAST(ST_ASGEOJSON(@@SF_SCHEMA@@.ST_BUFFER(@@SF_SCHEMA@@._FILTER_GEOG(GEOG), CAST(0.00000001 AS DOUBLE)) ) AS STRING), @@SF_SCHEMA@@.H3_POLYFILL(GEOG, RESOLUTION))
	ELSE []
    END
$$;
