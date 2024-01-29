const { createTable, deleteTable } = require('../../../../common/test-utils');

async function initializeDOSubscriptions () {
    await Promise.all([
        deleteTable('coords_sample')
    ]);
    await new Promise(resolve => setTimeout(resolve, 1000));
    await Promise.all([
        createTable(
            'coords_sample',
            './test/quadbin/fixtures/coords_sample.sql'
        )
    ]);
}

module.exports = initializeDOSubscriptions;