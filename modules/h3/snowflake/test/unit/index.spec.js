const lib = require('../../dist/index');
const version = require('../../package.json').version;

test('library defined', () => {
    expect(lib.geoToH3).toBeDefined();
    expect(lib.compact).toBeDefined();
    expect(lib.h3Distance).toBeDefined();
    expect(lib.h3IsValid).toBeDefined();
    expect(lib.hexRing).toBeDefined();
    expect(lib.h3IsPentagon).toBeDefined();
    expect(lib.kRing).toBeDefined();
    expect(lib.polyfill).toBeDefined();
    expect(lib.h3ToGeoBoundary).toBeDefined();
    expect(lib.h3ToChildren).toBeDefined();
    expect(lib.h3ToParent).toBeDefined();
    expect(lib.uncompact).toBeDefined();
    expect(lib.version).toBe(version);
});