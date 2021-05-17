const routingLib = require('../../dist/index');
const version = require('../../package.json').version;

test('routing library defined', () => {
    expect(routingLib.version).toBe(version);
});