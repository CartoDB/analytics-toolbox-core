const { deleteTable } = require('../../../../common/test-utils');

async function deleteTables () {
    await Promise.all([
        deleteTable('coords_sample')
    ]);
}

module.exports = deleteTables;