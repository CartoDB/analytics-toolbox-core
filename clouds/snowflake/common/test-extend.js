const { expect } = require('@jest/globals');

expect.extend({
    toBeCloseTo (received, expected, precision = 10) {

        function round (obj) {
            if (!obj) {
                return obj;
            }
            switch (typeof obj) {
            case 'array':
                return obj.map(round);
            case 'object':
                return Object.keys(obj).reduce((acc, key) => {
                    acc[key] = round(obj[key]);
                    return acc;
                }, {});
            case 'number':
                return +obj.toFixed(precision);
            default:
                return obj;
            }
        }

        expect(round(received)).toEqual(round(expected));

        return { pass: true };
    }
});