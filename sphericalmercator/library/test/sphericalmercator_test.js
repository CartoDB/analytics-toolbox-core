const fs = require('fs');
const assert = require('assert').strict;
/* Emulate how BigQuery would load the file */
global.eval(fs.readFileSync('../../sphericalmercator_library.js') + '');

describe('SPHERICALMERCATOR unit tests', () => {
    it('Version', async() => {
        assert.equal(sphericalmercatorVersion(), 1);
    });
});
