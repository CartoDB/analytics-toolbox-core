const fs = require('fs');
const path = require('path');

const { BigQuery } = require('@google-cloud/bigquery');

const BQ_PROJECT = process.env.BQ_PROJECT;
const BQ_PREFIX = process.env.BQ_PREFIX;
const BQ_DATASET = process.env.BQ_DATASET;

const client = new BigQuery({ projectId: `${BQ_PROJECT}` });

async function runQuery (query, options) {
    options = Object.assign({}, { 'timeoutMs' : 420000 }, options);
    query = replaceBQPrefix(query);
    const [rows] = await client.query(query, options);
    return rows;
}

function replaceBQPrefix (text) {
    return text.replace(/@@BQ_DATASET@@/g, BQ_DATASET).replace(/@@BQ_PREFIX@@/g, BQ_PREFIX);
}

async function loadTable (tablename, filepath, columns, viewName) {
    const metadata = {
        sourceFormat: 'CSV',
        skipLeadingRows: 1,
        schema: { fields: columns },
        writeDisposition: 'WRITE_TRUNCATE'
    };

    await client.dataset(`${BQ_PREFIX}carto`).table(tablename).load(filepath, metadata);
    if (viewName) {
        await createView(viewName, `SELECT * FROM \`${BQ_DATASET}.${tablename}\``);
    }
}

async function loadTableJSON (tablename, filepath, columns, viewName) {
    const metadata = {
        sourceFormat: 'NEWLINE_DELIMITED_JSON',
        schema: { fields: columns },
        writeDisposition: 'WRITE_TRUNCATE'
    };

    await client.dataset(`${BQ_PREFIX}carto`).table(tablename).load(filepath, metadata);
    if (viewName) {
        await createView(viewName, `SELECT * FROM \`${BQ_DATASET}.${tablename}\``);
    }
}

async function createView (viewName, query) {
    const options = {
        view: query
    };
    await client.dataset(`${BQ_PREFIX}carto`).createTable(viewName, options);
}

async function deleteTable (tablename) {
    const table = client.dataset(`${BQ_PREFIX}carto`).table(tablename);
    const exists = await table.exists();
    if (exists[0]) {
        await table.delete();
    }
}

function readJSONFixture (name, lib) {
    const filepath = path.join('.', 'test', lib, 'fixtures', `${name}.json`);
    return JSON.parse(fs.readFileSync(filepath));
}

function writeJSONFixture (name, lib, json) {
    const filepath = path.join('.', 'test', lib, 'fixtures', `${name}.json`);
    const data = JSON.stringify(json);
    fs.writeFileSync(filepath, data);
}

function writeNDJSONFixture (name, lib, json) {
    const filepath = path.join('.', 'test', lib, 'fixtures', `${name}.ndjson`);
    const data = json.map(JSON.stringify).join('\n');
    fs.writeFileSync(filepath, data);
}

async function cancelJob (jobId) {
    const job = bigquery.job(jobId);
    // Attempt to cancel job
    const [apiResult] = await job.cancel();
    return apiResult;
}

function sortByKey (list, key) {
    return list.sort((a, b) => (a[key] > b[key]) ? 1 : -1);
}

function sortByKeyAndRound (list, orderKey, roundedKeys, precision=10) {
    list = list.sort((a, b) => (a[orderKey] > b[orderKey]) ? 1 : -1);
    for (let row of list) {
        for (let roundKey of roundedKeys) {
            if (row[roundKey]) {
                row[roundKey] = row[roundKey].toPrecision(precision);
            }
        }
    }
    return list;
}

function normSql (txt) {
    return txt.replace(/\s+/g,' ').replace(/\s?,\s?/g, ',').replace(/\( /g, '(').replace(/ \)/g, ')').trim();
}

module.exports = {
    runQuery,
    loadTable,
    loadTableJSON,
    createView,
    deleteTable,
    readJSONFixture,
    writeJSONFixture,
    writeNDJSONFixture,
    cancelJob,
    sortByKey,
    sortByKeyAndRound,
    normSql
};