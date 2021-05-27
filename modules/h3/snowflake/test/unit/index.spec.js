const geoToH3 = require('../../dist/longlat_ash3').geoToH3;
const compact = require('../../dist/compact').compact;
const h3Distance = require('../../dist/distance').h3Distance;
const h3IsValid = require('../../dist/isvalid').h3IsValid;
const hexRing = require('../../dist/hexring').hexRing;
const h3IsPentagon = require('../../dist/ispentagon').h3IsPentagon;
const kRing = require('../../dist/kring').kRing;
const polyfill = require('../../dist/ash3_polyfill').polyfill;
const h3ToGeoBoundary = require('../../dist/boundary').h3ToGeoBoundary;
const h3ToChildren = require('../../dist/tochildren').h3ToChildren;
const h3ToParent = require('../../dist/toparent').h3ToParent;
const uncompact = require('../../dist/uncompact').uncompact;
const version = require('../../dist/version').version;

test('h3 library defined', () => {
    expect(geoToH3).toBeDefined();
    expect(compact).toBeDefined();
    expect(h3Distance).toBeDefined();
    expect(h3IsValid).toBeDefined();
    expect(hexRing).toBeDefined();
    expect(h3IsPentagon).toBeDefined();
    expect(kRing).toBeDefined();
    expect(polyfill).toBeDefined();
    expect(h3ToGeoBoundary).toBeDefined();
    expect(h3ToChildren).toBeDefined();
    expect(h3ToParent).toBeDefined();
    expect(uncompact).toBeDefined();
    expect(version).toBe(version);
});