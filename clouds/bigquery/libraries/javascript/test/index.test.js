const lib = require('../build/index');

test('accessors library defined', () => {
    expect(lib.accessors.featureCollection).toBeDefined();
    expect(lib.accessors.feature).toBeDefined();
    expect(lib.accessors.envelope).toBeDefined();
});

test('constructors library defined', () => {
    expect(lib.constructors.bezierSpline).toBeDefined();
    expect(lib.constructors.ellipse).toBeDefined();
});

test('h3 library defined', () => {
    expect(lib.h3.geoToH3).toBeDefined();
    expect(lib.h3.compact).toBeDefined();
    expect(lib.h3.h3Distance).toBeDefined();
    expect(lib.h3.h3IsValid).toBeDefined();
    expect(lib.h3.hexRing).toBeDefined();
    expect(lib.h3.h3IsPentagon).toBeDefined();
    expect(lib.h3.kRing).toBeDefined();
    expect(lib.h3.kRingDistances).toBeDefined();
    expect(lib.h3.polyfill).toBeDefined();
    expect(lib.h3.h3ToGeoBoundary).toBeDefined();
    expect(lib.h3.h3ToChildren).toBeDefined();
    expect(lib.h3.h3ToParent).toBeDefined();
    expect(lib.h3.uncompact).toBeDefined();
});

test('measurements library defined', () => {
    expect(lib.measurements.angle).toBeDefined();
    expect(lib.measurements.bearing).toBeDefined();
    expect(lib.measurements.featureCollection).toBeDefined();
    expect(lib.measurements.feature).toBeDefined();
    expect(lib.measurements.distanceWeight).toBeDefined();
});

test('placekey library defined', () => {
    expect(lib.placekey.placekeyIsValid).toBeDefined();
    expect(lib.placekey.h3ToPlacekey).toBeDefined();
    expect(lib.placekey.placekeyToH3).toBeDefined();
});

test('processing library defined', () => {
    expect(lib.processing.featureCollection).toBeDefined();
    expect(lib.processing.feature).toBeDefined();
    expect(lib.processing.voronoi).toBeDefined();
    expect(lib.processing.polygonToLine).toBeDefined();
});

test('quadkey library defined', () => {
    expect(lib.quadkey.bbox).toBeDefined();
    expect(lib.quadkey.toChildren).toBeDefined();
    expect(lib.quadkey.quadkeyFromQuadint).toBeDefined();
    expect(lib.quadkey.quadintFromQuadkey).toBeDefined();
    expect(lib.quadkey.quadintFromLocation).toBeDefined();
    expect(lib.quadkey.quadintToGeoJSON).toBeDefined();
    expect(lib.quadkey.geojsonToQuadints).toBeDefined();
    expect(lib.quadkey.ZXYFromQuadint).toBeDefined();
});

test('s2 library defined', () => {
    expect(lib.s2.keyToId).toBeDefined();
    expect(lib.s2.idToKey).toBeDefined();
    expect(lib.s2.latLngToKey).toBeDefined();
    expect(lib.s2.FromHilbertQuadKey).toBeDefined();
});

test('transformations library defined', () => {
    expect(lib.transformations.featureCollection).toBeDefined();
    expect(lib.transformations.feature).toBeDefined();
    expect(lib.transformations.buffer).toBeDefined();
    expect(lib.transformations.centerMean).toBeDefined();
    expect(lib.transformations.centerMedian).toBeDefined();
    expect(lib.transformations.centerOfMass).toBeDefined();
    expect(lib.transformations.concave).toBeDefined();
    expect(lib.transformations.destination).toBeDefined();
    expect(lib.transformations.greatCircle).toBeDefined();
    expect(lib.transformations.along).toBeDefined();
});