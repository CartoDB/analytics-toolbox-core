const { BigQuery } = require('@google-cloud/bigquery');

const BQ_PROJECT = process.env.BQ_PROJECT;
const BQ_DATASET = process.env.BQ_DATASET;

const client = new BigQuery({ projectId: `${BQ_PROJECT}` });

const runQuery = async (query, options) => {
    options = Object.assign({}, { 'timeoutMs' : 30000 }, options);
    query = query.replace('%PROJECT%', `\`${BQ_PROJECT}\``);
    query = query.replace('%DATASET%', `\`${BQ_DATASET}\``);
    const [rows] = await client.query(query, options);
    return rows
};

module.exports = {
    runQuery
}