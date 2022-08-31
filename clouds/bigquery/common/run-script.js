#!/usr/bin/env node

const fs = require('fs');

const { BigQuery } = require('@google-cloud/bigquery');
const cliProgress = require('cli-progress');

const BQ_PROJECT = process.env.BQ_PROJECT;
const BQ_PREFIX = `${BQ_PROJECT}.${process.env.BQ_PREFIX}`;
const BQ_LIBRARY_BUCKET = process.env.BQ_LIBRARY_BUCKET;

const options = {
    barsize: 60,
    barIncompleteChar: ' ',
    format:'{percentage}%|{bar}| {value}/{total} [{duration_formatted}<{eta_formatted}]'
};
const bar = new cliProgress.SingleBar(options, cliProgress.Presets.shades_classic);

const client = new BigQuery({ projectId: `${BQ_PROJECT}` });

async function runQueries (queries) {
    const query_options = { 'timeoutMs' : 120000 };
    const n = queries.length;
    bar.start(n, 0);
    for (let i = 0; i < n; i++) {
        let query = queries[i].replace(/@@BQ_PREFIX@@/g, BQ_PREFIX).replace(/@@BQ_LIBRARY_BUCKET@@/g, BQ_LIBRARY_BUCKET);

        const pattern = new RegExp(`${process.env.BQ_DATASET}._*(.*?)[(|\n]`);
        const result = query.match(pattern);
        sqlFunction = result && result[1]

        await client.query(query, query_options);
        bar.increment();
    }
    bar.stop(n);
}

const script = process.argv[2];
const content = fs.readFileSync(script).toString();
const separator = '\n-->\n';
const queries = content.split(separator);
let sqlFunction = '';

runQueries(queries).catch(error => {
    console.log(`\n[${sqlFunction}] ERROR: ${error}`);
    process.exit(1);
});