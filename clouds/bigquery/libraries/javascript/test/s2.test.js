const lib = require('../build/index');

test('s2 library defined', () => {
    expect(lib.s2.keyToId).toBeDefined();
    expect(lib.s2.idToKey).toBeDefined();
    expect(lib.s2.latLngToKey).toBeDefined();
    expect(lib.s2.FromHilbertQuadKey).toBeDefined();
});