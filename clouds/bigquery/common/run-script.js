#!/usr/bin/env node

const fs = require('fs');

const { BigQuery } = require('@google-cloud/bigquery');
const cliProgress = require('cli-progress');

const BQ_PROJECT = process.env.BQ_PROJECT;

const options = {
    barsize: 60,
    barIncompleteChar: ' ',
    format:'{percentage}%|{bar}| {value}/{total} [{duration_formatted}<{eta_formatted}]'
};
const bar = new cliProgress.SingleBar(options, cliProgress.Presets.shades_classic);

const client = new BigQuery({ projectId: `${BQ_PROJECT}`, timeout: 600000 });

async function runQueries (queries) {
    const query_options = { 'timeoutMs' : 120000 };
    const n = queries.length;
    bar.start(n, 0);
    for (let i = 0; i < n; i++) {
        let query = queries[i];

        const pattern = /(FUNCTION|PROCEDURE)\s+(.*?)[(\n]/g;
        const results = pattern.exec(query);
        const result = results && results.reverse()[0]
        sqlFunction = result && result.split('.').reverse()[0]

        await client.query(query, query_options);
        bar.increment();
    }
    bar.stop(n);
}

const script = process.argv[2];
let content = fs.readFileSync(script).toString();
const separator = '\n-->\n';
let sqlFunction = '';

if (process.env.SKIP_PROGRESS_BAR) {
    content = content.replaceAll(separator, '')
    runQueries([content]).catch(error => {
        console.log(`\nERROR: ${error}`);
        process.exit(1);
    });
} else {
    const queries = content.split(separator).filter(q => !!q);

    runQueries(queries).catch(error => {
        console.log(`\n[${sqlFunction}] ERROR: ${error}`);
        process.exit(1);
    });
}