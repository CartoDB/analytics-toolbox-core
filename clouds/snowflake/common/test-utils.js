const crypto = require('crypto');
const fs = require('fs');
const path = require('path');
const snowflake = require('snowflake-sdk');
const truncate = require('@turf/truncate').default;
const booleanEqual = require('@turf/boolean-equal').default;

snowflake.configure({ insecureConnect: true });

const connectionOptions = {
    account: process.env.SF_ACCOUNT,
    username: process.env.SF_USER,
    database: process.env.SF_DATABASE,
    schema: process.env.SF_PREFIX + process.env.SF_SCHEMA_DEFAULT,
    role: process.env.SF_ROLE
};

if (process.env.SF_PASSWORD) {
    connectionOptions.password = process.env.SF_PASSWORD;
} else if (process.env.SF_RSA_KEY) {
    const privateKeyObject = crypto.createPrivateKey({
        key: process.env.SF_RSA_KEY,
        format: 'pem',
        passphrase: process.env.SF_RSA_KEY_PASSWORD
    });
    connectionOptions.authenticator = 'SNOWFLAKE_JWT';
    connectionOptions.privateKey = privateKeyObject.export({
        format: 'pem',
        type: 'pkcs8'
    });
}

// Connect on first query rather than on import: jest imports a test file to
// discover its tests even when they are all skipped, so connecting at module
// scope left an HTTP request in flight after the suite finished and the
// environment was torn down.
//
// The promise itself is the cache, so concurrent callers share one connect and
// later callers reuse it. It is cleared on failure so a subsequent call retries
// rather than latching the error forever.
let connecting = null;

function getConnection () {
    if (!connecting) {
        const conn = snowflake.createConnection(connectionOptions);
        connecting = new Promise((resolve, reject) => {
            conn.connect((err) => {
                if (err) {
                    return reject(new Error(`Unable to connect: ${err.message}`));
                }
                return resolve(conn);
            });
        }).catch((err) => {
            connecting = null;
            throw err;
        });
    }
    return connecting;
}

async function execAsync (query) {
    const conn = await getConnection();
    return new Promise((resolve, reject) => {
        conn.execute({
            sqlText: query,
            complete: (err, stmt, rows) => {
                if (err) {
                    return reject(err);
                }
                return resolve(rows);
            }
        });
    });
}

async function runQuery (query) {
    query = query.replace(/@@SF_SCHEMA@@/g, process.env.SF_SCHEMA).replace(/@@SF_ROLE@@/g, process.env.SF_ROLE);
    const rows = await execAsync(query);
    return rows;
}

async function createTable (tablename, filepath) {
    const sql = fs.readFileSync(filepath);
    const query = `
      CREATE TABLE IF NOT EXISTS ${tablename} AS ${sql}
    `;
    await runQuery(query);
}

async function deleteTable (tablename) {
    const query = `
      DROP TABLE IF EXISTS ${tablename}
    `;
    await runQuery(query);
}

async function deleteView (tablename) {
    const query = `
      DROP VIEW IF EXISTS ${tablename}
    `;
    await runQuery(query);
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

async function existsTable (table) {
    try {
        const query = `SELECT * FROM ${table} LIMIT 0`;
        await runQuery(query);
        return true;
    } catch {
        return false;
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

function arrayDictsKeysToLower (array) {
    return array.map((item) => {
        const newItem = {};
        for (const key in item) {
            newItem[key.toLowerCase()] = item[key];
        }
        return newItem;
    });
}

function isGeometryCloseTo (actual, expected, precision = 6) {
    // Normalize both geometries to the same precision
    const normalizedActual = truncate(actual, { precision, mutate: false });
    const normalizedExpected = truncate(expected, { precision, mutate: false });

    // Use Turf's boolean-equal for geometric comparison
    return booleanEqual(normalizedActual, normalizedExpected);
}

module.exports = {
    runQuery,
    createTable,
    deleteTable,
    deleteView,
    sortByKey,
    approx,
    existsTable,
    readJSONFixture,
    writeJSONFixture,
    writeNDJSONFixture,
    arrayDictsKeysToLower,
    isGeometryCloseTo
}