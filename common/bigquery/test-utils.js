const { BigQuery } = require('@google-cloud/bigquery');

const BQ_PROJECT = process.env.BQ_PROJECT;
const BQ_DATASET_PREFIX = process.env.BQ_DATASET_PREFIX;
const BQ_PREFIX = `${BQ_PROJECT}.${BQ_DATASET_PREFIX}`;

const client = new BigQuery({ projectId: `${BQ_PROJECT}` });

async function runQuery (query, options) {
    options = Object.assign({}, { 'timeoutMs' : 30000 }, options);
    query = query.replace(/@@BQ_PREFIX@@/g, BQ_PREFIX);
    const [rows] = await client.query(query, options);
    return rows
}

function sortByKey (list, key) {
    return list.sort((a, b) => (a[key] > b[key]) ? 1 : -1);
}

module.exports = {
    runQuery,
    sortByKey
}