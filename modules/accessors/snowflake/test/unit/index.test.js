const accessorsLib = require('../../dist/index');
const version = require('../../package.json').version;

test('accessors library defined', () => {
    expect(accessorsLib.featureCollection).toBeDefined();
    expect(accessorsLib.feature).toBeDefined();
    expect(accessorsLib.envelope).toBeDefined();
    expect(accessorsLib.version).toBe(version);
});