#!/usr/bin/env node

const { BigQuery } = require('@google-cloud/bigquery');

const BQ_PROJECT = process.env.BQ_PROJECT;

const client = new BigQuery({ projectId: `${BQ_PROJECT}` });

function runQuery (query) {
    client.query(query, { timeoutMs : 120000 });
}

const query = process.argv[2];

runQuery(query);