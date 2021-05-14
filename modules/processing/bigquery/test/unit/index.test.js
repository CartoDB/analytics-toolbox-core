const lib = require('../../dist/index');
const version = require('../../package.json').version;

test('library defined', () => {
    expect(lib.featureCollection).toBeDefined();
    expect(lib.feature).toBeDefined();
    expect(lib.voronoi).toBeDefined();
    expect(lib.polygonToLine).toBeDefined();
    expect(lib.version).toBe(version);
});