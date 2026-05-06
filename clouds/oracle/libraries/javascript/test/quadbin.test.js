// Smoke test for the quadbin MLE module exports.
// Run via `make test` in libraries/javascript/.
const { polyfill } = require('../build/quadbin').quadbinLib;

test('quadbin library defined', () => {
    expect(polyfill).toBeDefined();
});

test('polyfill returns a JSON array of quadbin strings', () => {
    const polygon = JSON.stringify({
        type: 'Polygon',
        coordinates: [[
            [-3.71219873428345, 40.413365349070865],
            [-3.7144088745117, 40.40965661286395],
            [-3.70659828186035, 40.409525904775634],
            [-3.71219873428345, 40.413365349070865]
        ]]
    });
    const result = polyfill(polygon, 17);
    const cells = JSON.parse(result);
    expect(Array.isArray(cells)).toBe(true);
    expect(cells.length).toBeGreaterThan(0);
    // Each cell must be a string preserving full 64-bit precision.
    cells.forEach(cell => {
        expect(typeof cell).toBe('string');
        expect(cell).toMatch(/^\d+$/);
    });
});

test('polyfill returns "[]" for null inputs', () => {
    expect(polyfill(null, 17)).toBe('[]');
    expect(polyfill('{"type":"Point","coordinates":[0,0]}', null)).toBe('[]');
});