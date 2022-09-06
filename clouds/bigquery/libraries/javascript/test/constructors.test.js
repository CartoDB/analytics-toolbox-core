const lib = require('../build/index');

test('constructors library defined', () => {
    expect(lib.constructors.bezierSpline).toBeDefined();
    expect(lib.constructors.ellipse).toBeDefined();
});