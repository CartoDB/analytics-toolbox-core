const longlatAsH3Lib = require('../../dist/longlat_ash3');
const compactLib = require('../../dist/compact');
const distanceLib = require('../../dist/distance');
const isValidLib = require('../../dist/isvalid');
const hexRingLib = require('../../dist/hexring');
const isPentagonLib = require('../../dist/ispentagon');
const kringLib = require('../../dist/kring');
const kringDistancesLib = require('../../dist/kring_distances');
const asH3PolyfillLib = require('../../dist/ash3_polyfill');
const boundaryLib = require('../../dist/boundary');
const toChildrenLib = require('../../dist/tochildren');
const toParentLib = require('../../dist/toparent');
const uncompactLib = require('../../dist/uncompact');
const versionLib = require('../../dist/version');
const version = require('../../package.json').version;

test('h3 library defined', () => {
    expect(longlatAsH3Lib.geoToH3).toBeDefined();
    expect(compactLib.compact).toBeDefined();
    expect(distanceLib.h3Distance).toBeDefined();
    expect(isValidLib.h3IsValid).toBeDefined();
    expect(hexRingLib.hexRing).toBeDefined();
    expect(hexRingLib.h3IsValid).toBeDefined();
    expect(isPentagonLib.h3IsPentagon).toBeDefined();
    expect(kringLib.kRing).toBeDefined();
    expect(kringLib.h3IsValid).toBeDefined();
    expect(kringDistancesLib.kRingDistances).toBeDefined();
    expect(kringDistancesLib.h3IsValid).toBeDefined();
    expect(asH3PolyfillLib.polyfill).toBeDefined();
    expect(boundaryLib.h3ToGeoBoundary).toBeDefined();
    expect(boundaryLib.h3IsValid).toBeDefined();
    expect(toChildrenLib.h3ToChildren).toBeDefined();
    expect(toChildrenLib.h3IsValid).toBeDefined();
    expect(toParentLib.h3ToParent).toBeDefined();
    expect(toParentLib.h3IsValid).toBeDefined();
    expect(uncompactLib.uncompact).toBeDefined();
    expect(versionLib.version).toBe(version);
});