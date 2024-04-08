const compactLib = require('../build/h3_compact');
const isValidLib = require('../build/h3_isvalid');
const hexRingLib = require('../build/h3_hexring');
const isPentagonLib = require('../build/h3_ispentagon');
const h3PolyfillLib = require('../build/h3_polyfill');
const boundaryLib = require('../build/h3_boundary');
const kringDistancesLib = require('../build/h3_kring_distances');
const uncompactLib = require('../build/h3_uncompact');

test('h3 library defined', () => {
    expect(compactLib.compact).toBeDefined();
    expect(isValidLib.h3IsValid).toBeDefined();
    expect(hexRingLib.hexRing).toBeDefined();
    expect(hexRingLib.h3IsValid).toBeDefined();
    expect(isPentagonLib.h3IsPentagon).toBeDefined();
    expect(h3PolyfillLib.h3ToGeoBoundary).toBeDefined();
    expect(boundaryLib.h3ToGeoBoundary).toBeDefined();
    expect(boundaryLib.h3IsValid).toBeDefined();
    expect(kringDistancesLib.h3Distance).toBeDefined();
    expect(uncompactLib.uncompact).toBeDefined();
});