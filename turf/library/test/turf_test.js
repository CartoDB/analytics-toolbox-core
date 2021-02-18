const fs = require('fs');
const assert = require('assert').strict;
/* Emulate how BigQuery would load the file */
global.eval(fs.readFileSync('../../turf_library.js') + '');

describe('TURF unit tests', () => {
    it('Version', async() => {
        assert.equal(turfVersion(), 1);
    });
});
