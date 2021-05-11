const lib = require('../../dist/index');
const version = require('../../package.json').version;

test('library defined', () => {
    expect(lib.geoToH3).toBeDefined();
    expect(lib.version).toBe(version);
});
