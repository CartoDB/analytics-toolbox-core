const fs = require('fs');
const assert = require('assert').strict;
/* Emulate how BigQuery would load the file */
global.eval(fs.readFileSync('../../placekey_library.js') + '');

describe('PLACEKEY unit tests', () => {
    it('Version', async() => {
        assert.equal(placekeyVersion(), 1);
    });
});
