const lib = require('../build/index');

test('polyfillQuery should work', () => {
    expect(lib.quadbin.polyfillQuery(162)).toEqual([-90, 0, 0, 66.51326044311186]);
});
