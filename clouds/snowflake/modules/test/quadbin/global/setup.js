const { createTable, deleteTable } = require('../../../../common/test-utils');

async function initializeTables () {
    await Promise.all([
        createTable(
            'coords_sample',
            './test/quadbin/fixtures/coords_sample.sql'
        )
    ]);
}

module.exports = initializeTables;