const constructorsLib = require('../build/constructors');

test('constructors library defined', () => {
    expect(constructorsLib.bezierSpline).toBeDefined();
    expect(constructorsLib.ellipse).toBeDefined();
});