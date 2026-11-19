const fs = require('fs');
const path = require('path');

const { BigQuery } = require('@google-cloud/bigquery');

const BQ_PROJECT = process.env.BQ_PROJECT;
const BQ_PREFIX = process.env.BQ_PREFIX;
const BQ_DATASET = process.env.BQ_DATASET;

const client = new BigQuery({ projectId: `${BQ_PROJECT}` });

// BigQuery intermittently rejects remote-function calls made inside scripts with this
// error even when nothing else runs in the project. Re-running the same statement is
// safe: the resumable procedures pick up from their partial tables.
const REMOTE_FUNCTION_RATE_LIMIT = /too many concurrent queries with remote functions/;
const RETRY_DELAYS_MS = [5000, 10000, 20000, 30000];

async function runQuery (query, options) {
    options = Object.assign({}, { timeoutMs : 120000 }, options);
    query = replaceBQPrefix(query);
    for (let attempt = 0; ; attempt++) {
        try {
            const [rows] = await client.query(query, options);
            return rows;
        } catch (error) {
            if (!REMOTE_FUNCTION_RATE_LIMIT.test(error.message) || attempt >= RETRY_DELAYS_MS.length) {
                throw error;
            }
            // Jitter keeps parallel Jest workers from retrying in lockstep
            const delay = Math.round(RETRY_DELAYS_MS[attempt] * (0.5 + Math.random()));
            console.warn(`Remote-function rate limit, retrying in ${delay} ms (retry ${attempt + 1}/${RETRY_DELAYS_MS.length})`);
            await new Promise((resolve) => setTimeout(resolve, delay));
        }
    }
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

// Floating-point results can drift in the last digits between releases. approx(expected) returns
// `expected` with every number, and every number inside a string (WKT, GeoJSON), replaced by a
// matcher that accepts the value within `significantDigits` significant digits. A change in any
// earlier digit still fails. Numbers beyond 1e9 (ids) and strings without a decimal stay exact.
// Use it as the expected value of the standard matchers:
//   expect(rows).toEqual(approx(fixture))
//   expect(rows).toEqual(expect.arrayContaining(approx(fixture)))
const NUMBER = /-?\d+(?:\.\d+)?(?:[eE][-+]?\d+)?/g;

function magnitude (number) {
    return number === 0 ? 0 : Math.floor(Math.log10(Math.abs(number)));
}

function tolerance (expected, significantDigits) {
    return Math.pow(10, magnitude(expected) - (significantDigits - 1)) / 2;
}

class ApproxText {
    constructor (expected, significantDigits) {
        this.$$typeof = Symbol.for('jest.asymmetricMatcher');
        this.expected = expected;
        this.significantDigits = significantDigits;
        this.template = expected.replace(NUMBER, '#');
        this.numbers = expected.match(NUMBER).map(Number);
    }

    asymmetricMatch (received) {
        if (typeof received !== 'string' || received.replace(NUMBER, '#') !== this.template) {
            return false;
        }
        const numbers = received.match(NUMBER).map(Number);
        return numbers.every(
            (number, i) => Math.abs(number - this.numbers[i]) < tolerance(this.numbers[i], this.significantDigits)
        );
    }

    toString () {
        return 'ApproxText';
    }

    toAsymmetricMatcher () {
        return `ApproxText ${JSON.stringify(this.expected)}`;
    }
}

function approx (expected, significantDigits = 10) {
    if (typeof expected === 'number') {
        if (!Number.isFinite(expected) || Math.abs(expected) > 1e9) {
            return expected;
        }
        return expect.closeTo(expected, significantDigits - 1 - magnitude(expected));
    }
    if (typeof expected === 'string') {
        return /\d\.\d/.test(expected) ? new ApproxText(expected, significantDigits) : expected;
    }
    if (Array.isArray(expected)) {
        return expected.map(item => approx(item, significantDigits));
    }
    if (expected && Object.getPrototypeOf(expected) === Object.prototype) {
        return Object.fromEntries(
            Object.entries(expected).map(([key, item]) => [key, approx(item, significantDigits)])
        );
    }
    return expected;
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
    approx,
    normSql
};