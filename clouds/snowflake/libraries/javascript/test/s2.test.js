const s2Lib = require('../build/s2');

test('s2 library defined', () => {
    expect(s2Lib.keyToId).toBeDefined();
    expect(s2Lib.idToKey).toBeDefined();
    expect(s2Lib.latLngToKey).toBeDefined();
    expect(s2Lib.FromHilbertQuadKey).toBeDefined();
});