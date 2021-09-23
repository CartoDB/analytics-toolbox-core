const h3Lib = require('../../dist/index');
const version = require('../../package.json').version;

test('h3 library defined', () => {
    expect(h3Lib.geoToH3).toBeDefined();
    expect(h3Lib.compact).toBeDefined();
    expect(h3Lib.h3Distance).toBeDefined();
    expect(h3Lib.h3IsValid).toBeDefined();
    expect(h3Lib.hexRing).toBeDefined();
    expect(h3Lib.h3IsPentagon).toBeDefined();
    expect(h3Lib.kRing).toBeDefined();
    expect(h3Lib.kRingDistances).toBeDefined();
    expect(h3Lib.polyfill).toBeDefined();
    expect(h3Lib.h3ToGeoBoundary).toBeDefined();
    expect(h3Lib.h3ToChildren).toBeDefined();
    expect(h3Lib.h3ToParent).toBeDefined();
    expect(h3Lib.uncompact).toBeDefined();
    expect(h3Lib.version).toBe(version);
});