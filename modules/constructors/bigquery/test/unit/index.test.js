const constructorsLib = require('../../dist/index');
const version = require('../../package.json').version;

test('constructors library defined', () => {
    expect(constructorsLib.bezierSpline).toBeDefined();
    expect(constructorsLib.ellipse).toBeDefined();
    expect(constructorsLib.version).toBe(version);
});