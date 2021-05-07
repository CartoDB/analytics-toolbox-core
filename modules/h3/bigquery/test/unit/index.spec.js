const version = require('../../package.json').version;
const lib = require('../../lib/index');

test('version', () => {
    expect(lib.version).toBe(version);
});

test('geoToH3', () => {
    expect(lib.geoToH3).toBeDefined();
});
