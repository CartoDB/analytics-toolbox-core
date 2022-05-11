const quadkeyLib = require('../../dist/index');
const version = require('../../package.json').version;

test('quadkey library defined', () => {
    expect(quadkeyLib.version).toBe(version);
});