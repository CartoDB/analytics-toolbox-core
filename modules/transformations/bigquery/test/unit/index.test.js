const lib = require('../../dist/index');
const version = require('../../package.json').version;

test('library defined', () => {
    expect(lib.version).toBe(version);
    expect(lib.featureCollection).toBeDefined();
    expect(lib.feature).toBeDefined();
    expect(lib.buffer).toBeDefined();
    expect(lib.centerMean).toBeDefined();
    expect(lib.centerMedian).toBeDefined();
    expect(lib.centerOfMass).toBeDefined();
    expect(lib.concave).toBeDefined();
    expect(lib.destination).toBeDefined();
    expect(lib.greatCircle).toBeDefined();
    expect(lib.along).toBeDefined();
});