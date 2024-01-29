const { deleteTable } = require('../../../../common/test-utils');

async function removeDOSubscriptions () {
    await Promise.all([
        deleteTable('coords_sample')
    ]);
}

module.exports = removeDOSubscriptions;