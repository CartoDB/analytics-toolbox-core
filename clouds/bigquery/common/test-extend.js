const { expect } = require('@jest/globals');

// Results from the warehouse can drift in the last digits between runs, so numbers
// are compared with a relative tolerance instead of rounding both sides and
// requiring exact equality (which fails whenever the drift crosses a rounding boundary).
const MAX_TOLERANCE_DIGITS = 8;

function tolerance (precision, expected) {
    return Math.pow(10, -Math.min(precision, MAX_TOLERANCE_DIGITS)) * Math.max(1, Math.abs(expected));
}

function isClose (received, expected, precision) {
    if (typeof received === 'number' && typeof expected === 'number') {
        return received === expected || Math.abs(received - expected) <= tolerance(precision, expected);
    }
    if (Array.isArray(received) && Array.isArray(expected)) {
        return received.length === expected.length &&
            received.every((item, i) => isClose(item, expected[i], precision));
    }
    if (received && expected && typeof received === 'object' && typeof expected === 'object') {
        const receivedKeys = Object.keys(received);
        const expectedKeys = Object.keys(expected);
        return receivedKeys.length === expectedKeys.length &&
            expectedKeys.every(key => key in received && isClose(received[key], expected[key], precision));
    }
    return Object.is(received, expected) || received === expected;
}

expect.extend({
    toBeCloseTo (received, expected, precision = 10) {
        const pass = isClose(received, expected, precision);
        return {
            pass,
            message: () => `expected ${this.utils.printReceived(received)} ` +
                `${pass ? 'not ' : ''}to be close to ${this.utils.printExpected(expected)}`
        };
    },

    // Every expected row must match a received row: numbers within tolerance, everything else equal
    toContainRowsCloseTo (received, expectedRows, precision = 10) {
        const missing = expectedRows.filter(
            expectedRow => !received.some(row => isClose(row, expectedRow, precision))
        );
        const pass = missing.length === 0;
        return {
            pass,
            message: () => pass
                ? 'expected the rows not to contain the expected rows'
                : `${missing.length} of ${expectedRows.length} expected rows were not found. ` +
                    `First missing: ${this.utils.printExpected(missing[0])}`
        };
    }
});