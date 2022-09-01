const coreLib = require('../build/index');


test('transformations library defined', () => {
    expect(coreLib.transformations.featureCollection).toBeDefined();
    expect(coreLib.transformations.feature).toBeDefined();
    expect(coreLib.transformations.buffer).toBeDefined();
    expect(coreLib.transformations.centerMean).toBeDefined();
    expect(coreLib.transformations.centerMedian).toBeDefined();
    expect(coreLib.transformations.centerOfMass).toBeDefined();
    expect(coreLib.transformations.concave).toBeDefined();
    expect(coreLib.transformations.destination).toBeDefined();
    expect(coreLib.transformations.greatCircle).toBeDefined();
    expect(coreLib.transformations.along).toBeDefined();
});