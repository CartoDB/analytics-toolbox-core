const measurementsLib = require('../build/measurements');

test('measurements library defined', () => {
    expect(measurementsLib.angle).toBeDefined();
    expect(measurementsLib.bearing).toBeDefined();
    expect(measurementsLib.featureCollection).toBeDefined();
    expect(measurementsLib.feature).toBeDefined();
    expect(measurementsLib.distanceWeight).toBeDefined();
});