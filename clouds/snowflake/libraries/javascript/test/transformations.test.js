const alongLib = require('../build/transformations_along');
const bufferLib = require('../build/transformations_buffer');
const centerLib = require('../build/transformations_center');
const concaveLib = require('../build/transformations_concave');
const destinationLib = require('../build/transformations_destination');
const greatCircleLib = require('../build/transformations_greatcircle');

test('transformations library defined', () => {
    expect(alongLib.along).toBeDefined();
    expect(bufferLib.buffer).toBeDefined();
    expect(centerLib.feature).toBeDefined();
    expect(centerLib.centerMean).toBeDefined();
    expect(centerLib.centerMedian).toBeDefined();
    expect(centerLib.centerOfMass).toBeDefined();
    expect(concaveLib.featureCollection).toBeDefined();
    expect(concaveLib.multiPoint).toBeDefined();
    expect(concaveLib.cleanCoords).toBeDefined();
    expect(concaveLib.point).toBeDefined();
    expect(concaveLib.lineString).toBeDefined();
    expect(destinationLib.destination).toBeDefined();
    expect(greatCircleLib.greatCircle).toBeDefined();
});