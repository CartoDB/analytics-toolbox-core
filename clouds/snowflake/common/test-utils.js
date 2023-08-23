const fs = require('fs');
const path = require('path');
const snowflake = require('snowflake-sdk');

snowflake.configure({ insecureConnect: true })
const connection = snowflake.createConnection({
    account: process.env.SF_ACCOUNT,
    username: process.env.SF_USER,
    password: process.env.SF_PASSWORD,
    database: process.env.SF_DATABASE,
    schema: process.env.SF_PREFIX + process.env.SF_SCHEMA_DEFAULT,
    role: process.env.SF_ROLE
});

connection.connect((err) => {
    if (err) {
        console.error(`Unable to connect: ${err.message}`);
    } else {
        // Optional: store the connection ID.
        //const connection_ID = conn.getId();
    }
});

function execAsync (query) {
    return new Promise((resolve, reject) => {
        connection.execute({
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

module.exports = {
    runQuery,
    createTable,
    deleteTable,
    sortByKey,
    sortByKeyAndRound,
    existsTable,
    readJSONFixture,
    writeJSONFixture,
    writeNDJSONFixture,
    arrayDictsKeysToLower
}