const quadbinLib = require('../../dist/index');
const version = require('../../package.json').version;

test('quadbin library defined', () => {
    expect(quadbinLib.version).toBe(version);
    expect(quadbinLib.getQuadbinPolygon).toBeDefined();
});