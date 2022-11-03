const s2Lib = require('../build/s2');
const s2PolyfillBboxLib = require('../build/s2_polyfill_bbox');

test('s2 library defined', () => {
    expect(s2Lib.keyToId).toBeDefined();
    expect(s2Lib.idToKey).toBeDefined();
    expect(s2Lib.latLngToKey).toBeDefined();
    expect(s2Lib.FromHilbertQuadKey).toBeDefined();
    expect(s2PolyfillBboxLib.polyfillBbox).toBeDefined();
});