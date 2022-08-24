#!/usr/bin/env node

const fs = require('fs');

const snowflake = require('snowflake-sdk');

const SF_PREFIX = `${process.env.SF_DATABASE}.${process.env.SF_PREFIX}`;

snowflake.configure({ insecureConnect: true });

const connection = snowflake.createConnection({
    account: process.env.SF_ACCOUNT,
    username: process.env.SF_USER,
    password: process.env.SF_PASSWORD,
    database: process.env.SF_DATABASE,
    schema: process.env.SF_SCHEMA,
    role: process.env.SF_ROLE
});

connection.connect((err) => {
    if (err) {
        console.error(`Unable to connect: ${err.message}`);
    }
});

function runQuery (query) {
    query = query.replace(/@@SF_PREFIX@@/g, SF_PREFIX);
    connection.execute({
        sqlText: query,
        complete: (err, stmt, rows) => {
            if (err) {
                console.log(err.message);
            }
        }
    });
}

const script = process.argv[2];

const content = fs.readFileSync(script).toString();

// TODO: use a SQL splitter to show the progress
const query = `BEGIN
${content}
END;`

runQuery(query);