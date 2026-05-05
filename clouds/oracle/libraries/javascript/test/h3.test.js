// Smoke test for the h3 MLE module exports.
// Run via `make test` in libraries/javascript/.
const h3Lib = require('../build/h3').h3Lib;

test('h3 library defined', () => {
    expect(h3Lib.kring).toBeDefined();
    expect(h3Lib.hexring).toBeDefined();
    expect(h3Lib.kringDistances).toBeDefined();
    expect(h3Lib.distance).toBeDefined();
    expect(h3Lib.toChildren).toBeDefined();
    expect(h3Lib.compact).toBeDefined();
    expect(h3Lib.uncompact).toBeDefined();
    expect(h3Lib.polyfill).toBeDefined();
});

test('kring returns a JSON array of h3 hex strings', () => {
    const cells = JSON.parse(h3Lib.kring('8928308280fffff', 1));
    expect(Array.isArray(cells)).toBe(true);
    expect(cells.length).toBe(7); // origin + 6 neighbours
    cells.forEach(c => expect(c).toMatch(/^[0-9a-f]+$/));
});

test('kring returns "[]" for invalid inputs', () => {
    expect(h3Lib.kring(null, 1)).toBe('[]');
    expect(h3Lib.kring('8928308280fffff', null)).toBe('[]');
    expect(h3Lib.kring('not_a_cell', 1)).toBe('[]');
});

test('polyfill returns a JSON array of h3 hex strings', () => {
    const polygon = JSON.stringify({
        type: 'Polygon',
        coordinates: [[
            [-3.71219873428345, 40.413365349070865],
            [-3.7144088745117, 40.40965661286395],
            [-3.70659828186035, 40.409525904775634],
            [-3.71219873428345, 40.413365349070865]
        ]]
    });
    const cells = JSON.parse(h3Lib.polyfill(polygon, 9));
    expect(Array.isArray(cells)).toBe(true);
});

test('polyfill returns "[]" for null inputs', () => {
    expect(h3Lib.polyfill(null, 9)).toBe('[]');
    expect(h3Lib.polyfill('{"type":"Polygon","coordinates":[]}', null)).toBe('[]');
});