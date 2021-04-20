const fs = require('fs');
const assert = require('assert').strict;
/* Emulate how BigQuery would load the file */
eval(fs.readFileSync('../../measurement_library.js')+'');

describe('MEASUREMENT unit tests', () => {

    it ('Version', async () => {
        assert.equal(measurementVersion(), '1.0.0');
    });
});
