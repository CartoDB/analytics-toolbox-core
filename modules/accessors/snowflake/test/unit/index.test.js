const accessorsLib = require('../../dist/index');
const version = require('../../package.json').version;

test('accessors library defined', () => {
    expect(accessorsLib.version).toBe(version);
});