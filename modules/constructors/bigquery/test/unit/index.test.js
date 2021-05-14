const lib = require('../../dist/index');
const version = require('../../package.json').version;

test('library defined', () => {
    expect(lib.bezierSpline).toBeDefined();
    expect(lib.ellipse).toBeDefined();
    expect(lib.version).toBe(version);
});