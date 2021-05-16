const transformationsLib = require('../../dist/index');
const version = require('../../package.json').version;

test('transformations library defined', () => {
    expect(transformationsLib.version).toBe(version);
    expect(transformationsLib.featureCollection).toBeDefined();
    expect(transformationsLib.feature).toBeDefined();
    expect(transformationsLib.buffer).toBeDefined();
    expect(transformationsLib.centerMean).toBeDefined();
    expect(transformationsLib.centerMedian).toBeDefined();
    expect(transformationsLib.centerOfMass).toBeDefined();
    expect(transformationsLib.concave).toBeDefined();
    expect(transformationsLib.destination).toBeDefined();
    expect(transformationsLib.greatCircle).toBeDefined();
    expect(transformationsLib.along).toBeDefined();
});