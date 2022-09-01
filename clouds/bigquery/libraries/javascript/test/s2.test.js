const coreLib = require('../build/index');

test('s2 library defined', () => {
    expect(coreLib.s2.keyToId).toBeDefined();
    expect(coreLib.s2.idToKey).toBeDefined();
    expect(coreLib.s2.latLngToKey).toBeDefined();
    expect(coreLib.s2.FromHilbertQuadKey).toBeDefined();
});