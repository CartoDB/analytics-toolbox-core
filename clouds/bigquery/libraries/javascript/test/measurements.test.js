const coreLib = require('../build/index');

test('measurements library defined', () => {
    expect(coreLib.measurements.angle).toBeDefined();
    expect(coreLib.measurements.bearing).toBeDefined();
    expect(coreLib.measurements.featureCollection).toBeDefined();
    expect(coreLib.measurements.feature).toBeDefined();
    expect(coreLib.measurements.distanceWeight).toBeDefined();
});