#!/usr/bin/env node

const { BigQuery } = require('@google-cloud/bigquery');

const BQ_PROJECT = process.env.BQ_PROJECT;

const client = new BigQuery({ projectId: `${BQ_PROJECT}` });

function runQuery (query) {
    const query_options = { 'timeoutMs' : 120000 };
    client.query(query, query_options);
}

const query = process.argv[2];

runQuery(query);