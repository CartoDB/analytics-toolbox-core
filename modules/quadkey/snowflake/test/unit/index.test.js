const lib = require('../../dist/index');
const version = require('../../package.json').version;

test('library defined', () => {
    expect(lib.bbox).toBeDefined();
    expect(lib.kring).toBeDefined();
    expect(lib.sibling).toBeDefined();
    expect(lib.toChildren).toBeDefined();
    expect(lib.quadkeyFromQuadint).toBeDefined();
    expect(lib.quadintFromQuadkey).toBeDefined();
    expect(lib.quadintFromLocation).toBeDefined();
    expect(lib.quadintToGeoJSON).toBeDefined();
    expect(lib.geojsonToQuadints).toBeDefined();
    expect(lib.ZXYFromQuadint).toBeDefined();
    expect(lib.version).toBe(version);
});
