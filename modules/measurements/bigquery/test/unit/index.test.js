const lib = require('../../dist/index');
const version = require('../../package.json').version;

test('library defined', () => {
    expect(lib.angle).toBeDefined();
    expect(lib.bearing).toBeDefined();
    expect(lib.featureCollection).toBeDefined();
    expect(lib.feature).toBeDefined();
    expect(lib.distanceWeight).toBeDefined();
    expect(lib.version).toBe(version);
});