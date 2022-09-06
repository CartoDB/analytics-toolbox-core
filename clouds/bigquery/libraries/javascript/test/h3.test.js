const lib = require('../build/index');

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