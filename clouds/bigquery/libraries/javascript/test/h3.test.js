const coreLib = require('../build/index');

test('h3 library defined', () => {
    expect(coreLib.h3.geoToH3).toBeDefined();
    expect(coreLib.h3.compact).toBeDefined();
    expect(coreLib.h3.h3Distance).toBeDefined();
    expect(coreLib.h3.h3IsValid).toBeDefined();
    expect(coreLib.h3.hexRing).toBeDefined();
    expect(coreLib.h3.h3IsPentagon).toBeDefined();
    expect(coreLib.h3.kRing).toBeDefined();
    expect(coreLib.h3.kRingDistances).toBeDefined();
    expect(coreLib.h3.polyfill).toBeDefined();
    expect(coreLib.h3.h3ToGeoBoundary).toBeDefined();
    expect(coreLib.h3.h3ToChildren).toBeDefined();
    expect(coreLib.h3.h3ToParent).toBeDefined();
    expect(coreLib.h3.uncompact).toBeDefined();
});