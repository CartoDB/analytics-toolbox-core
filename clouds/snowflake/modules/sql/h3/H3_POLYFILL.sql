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

CREATE OR REPLACE SECURE FUNCTION @@SF_SCHEMA@@.H3_POLYFILL_MODE
(geog GEOGRAPHY, resolution INT, mode STRING)
RETURNS ARRAY
IMMUTABLE
AS $$
    CASE WHEN GEOG IS NULL OR RESOLUTION NOT BETWEEN 0 AND 15 THEN []
	WHEN MODE = 'center' THEN COALESCE(H3_POLYGON_TO_CELLS_STRINGS(TO_GEOGRAPHY(@@SF_SCHEMA@@._HEMI_SPLIT(CAST(ST_ASGEOJSON(GEOG) AS STRING))), RESOLUTION), [])
	WHEN MODE = 'intersects' THEN COALESCE(H3_COVERAGE_STRINGS(TO_GEOGRAPHY(@@SF_SCHEMA@@._HEMI_SPLIT(CAST(ST_ASGEOJSON(GEOG) AS STRING))), RESOLUTION), [])
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
