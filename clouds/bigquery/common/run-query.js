#!/usr/bin/env node

const { BigQuery } = require('@google-cloud/bigquery');

const BQ_PROJECT = process.env.BQ_PROJECT;
const BQ_PREFIX = `${BQ_PROJECT}.${process.env.BQ_PREFIX}`;

const client = new BigQuery({ projectId: `${BQ_PROJECT}` });

function runQuery (query) {
    query = query.replace(/@@BQ_PREFIX@@/g, BQ_PREFIX);
    const query_options = { 'timeoutMs' : 120000 };
    client.query(query, query_options);
}

const query = process.argv[2];

runQuery(query);