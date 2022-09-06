const lib = require('../build/index');


test('transformations library defined', () => {
    expect(lib.transformations.featureCollection).toBeDefined();
    expect(lib.transformations.feature).toBeDefined();
    expect(lib.transformations.buffer).toBeDefined();
    expect(lib.transformations.centerMean).toBeDefined();
    expect(lib.transformations.centerMedian).toBeDefined();
    expect(lib.transformations.centerOfMass).toBeDefined();
    expect(lib.transformations.concave).toBeDefined();
    expect(lib.transformations.destination).toBeDefined();
    expect(lib.transformations.greatCircle).toBeDefined();
    expect(lib.transformations.along).toBeDefined();
});