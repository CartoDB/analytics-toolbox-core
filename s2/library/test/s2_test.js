const fs = require('fs');
const assert = require('assert').strict;
/* Emulate how BigQuery would load the file */
global.eval(fs.readFileSync('../../s2_library.js') + '');

describe('S2 unit tests', () => {
    it('Version', async() => {
        assert.equal(s2Version(), 1);
    });
});
