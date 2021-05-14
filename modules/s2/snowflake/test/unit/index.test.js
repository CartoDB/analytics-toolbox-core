const lib = require('../../dist/index');
const version = require('../../package.json').version;

test('library defined', () => {
    expect(lib.keyToId).toBeDefined();
    expect(lib.idToKey).toBeDefined();
    expect(lib.latLngToKey).toBeDefined();
    expect(lib.FromHilbertQuadKey).toBeDefined();
    expect(lib.version).toBe(version);
});
