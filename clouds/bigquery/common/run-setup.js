#!/usr/bin/env node

const fs = require('fs');

const { BigQuery } = require('@google-cloud/bigquery');

const BQ_PROJECT = process.env.BQ_PROJECT;

const client = new BigQuery({ projectId: `${BQ_PROJECT}` });

async function runSetup () {
    const options = {
        api_base_url: process.env.BQ_API_BASE_URL,
        lds_token: process.env.BQ_LDS_TOKEN,
        lds_connection: process.env.BQ_LDS_CONNECTION,
        lds_endpoint: process.env.BQ_LDS_ENDPOINT,
        gateway_connection: process.env.BQ_GATEWAY_CONNECTION,
        gateway_endpoint: process.env.BQ_GATEWAY_ENDPOINT
    }
    const query = `CALL \`${process.env.BQ_DATASET}.SETUP\`(R'''${JSON.stringify(options)}''')`

    const query_options = { 'timeoutMs' : 200000 };
    await client.query(query, query_options);
}

runSetup().catch(error => {
    console.log(`\nSETUP ERROR: ${error}`);
    process.exit(1);
});