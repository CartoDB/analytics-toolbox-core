const fs = require('fs');
const assert = require('assert').strict;
/* Emulate how BigQuery would load the file */
global.eval(fs.readFileSync('../../turf_library.js') + '');

describe('TURF unit tests', () => {
    it('Version', async() => {
        assert.equal(turfVersion(), 1);
    });
});
describe('BBOX unit tests', () => {
// Fixtures
    const pt = turf.point([102.0, 0.5]);
    const line = turf.lineString([
        [102.0, -10.0],
        [103.0, 1.0],
        [104.0, 0.0],
        [130.0, 4.0]
    ]);
    const poly = turf.polygon([
        [
            [101.0, 0.0],
            [101.0, 1.0],
            [100.0, 1.0],
            [100.0, 0.0],
            [101.0, 0.0]
        ]
    ]);
    const multiLine = turf.multiLineString([
        [
            [100.0, 0.0],
            [101.0, 1.0]
        ],
        [
            [102.0, 2.0],
            [103.0, 3.0]
        ]
    ]);
    const multiPoly = turf.multiPolygon([
        [
            [
                [102.0, 2.0],
                [103.0, 2.0],
                [103.0, 3.0],
                [102.0, 3.0],
                [102.0, 2.0]
            ]
        ],
        [
            [
                [100.0, 0.0],
                [101.0, 0.0],
                [101.0, 1.0],
                [100.0, 1.0],
                [100.0, 0.0]
            ],
            [
                [100.2, 0.2],
                [100.8, 0.2],
                [100.8, 0.8],
                [100.2, 0.8],
                [100.2, 0.2]
            ]
        ]
    ]);
    const fc = turf.featureCollection([pt, line, poly, multiLine, multiPoly]);
    it('bbox', async() => {
    // FeatureCollection
        const fcBBox = turf.bbox(fc);
        assert.deepEqual(fcBBox, [100, -10, 130, 4], 'featureCollection');

        // Point
        const ptBBox = turf.bbox(pt);
        assert.deepEqual(ptBBox, [102, 0.5, 102, 0.5], 'point');

        // Line
        const lineBBox = turf.bbox(line);
        assert.deepEqual(lineBBox, [102, -10, 130, 4], 'lineString');

        // Polygon
        const polyExtent = turf.bbox(poly);
        assert.deepEqual(polyExtent, [100, 0, 101, 1], 'polygon');

        // MultiLineString
        const multiLineBBox = turf.bbox(multiLine);
        assert.deepEqual(multiLineBBox, [100, 0, 103, 3], 'multiLineString');

        // MultiPolygon
        const multiPolyBBox = turf.bbox(multiPoly);
        assert.deepEqual(multiPolyBBox, [100, 0, 103, 3], 'multiPolygon');
    });

    it('bbox -- throws', async() => {
        assert.throws(
            () => turf.bbox({}),
            /Unknown Geometry Type/,
            'unknown geometry type error'
        );
    });

    it('bbox -- null geometries', async() => {
        assert.deepEqual(turf.bbox(turf.feature(null)), [Infinity, Infinity, -Infinity, -Infinity]);
    });
});
