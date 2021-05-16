const s2Lib = require('../../dist/index');
const version = require('../../package.json').version;

test('s2 library defined', () => {
    expect(s2Lib.keyToId).toBeDefined();
    expect(s2Lib.idToKey).toBeDefined();
    expect(s2Lib.latLngToKey).toBeDefined();
    expect(s2Lib.FromHilbertQuadKey).toBeDefined();
    expect(s2Lib.version).toBe(version);
});