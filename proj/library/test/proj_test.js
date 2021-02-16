const fs = require('fs');
const assert = require('assert').strict;
/* Emulate how BigQuery would load the file */
global.eval(fs.readFileSync('../../proj_library.js') + '');

describe('PROJ unit tests', () => {
    it('Version', async() => {
        assert.equal(projVersion(), 1);
    });
});
