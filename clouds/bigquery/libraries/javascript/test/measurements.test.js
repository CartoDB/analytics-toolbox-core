const lib = require('../build/index');

test('measurements library defined', () => {
    expect(lib.measurements.angle).toBeDefined();
    expect(lib.measurements.bearing).toBeDefined();
    expect(lib.measurements.featureCollection).toBeDefined();
    expect(lib.measurements.feature).toBeDefined();
    expect(lib.measurements.distanceWeight).toBeDefined();
});