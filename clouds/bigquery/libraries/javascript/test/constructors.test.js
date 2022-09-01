const coreLib = require('../build/index');

test('constructors library defined', () => {
    expect(coreLib.constructors.bezierSpline).toBeDefined();
    expect(coreLib.constructors.ellipse).toBeDefined();
});