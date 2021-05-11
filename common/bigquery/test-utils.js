const { BigQuery } = require('@google-cloud/bigquery');

const BQ_PROJECT = process.env.BQ_PROJECT;
const BQ_PREFIX = process.env.BQ_PREFIX;

const client = new BigQuery({ projectId: `${BQ_PROJECT}` });

const runQuery = async (query, options) => {
    options = Object.assign({}, { 'timeoutMs' : 30000 }, options);
    query = query.replace('@@BQ_PREFIX@@', BQ_PREFIX);
    const [rows] = await client.query(query, options);
    return rows
};

module.exports = {
    runQuery
}