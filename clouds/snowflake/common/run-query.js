#!/usr/bin/env node

const snowflake = require('snowflake-sdk');

snowflake.configure({ insecureConnect: true });

const connection = snowflake.createConnection({
    account: process.env.SF_ACCOUNT,
    username: process.env.SF_USER,
    password: process.env.SF_PASSWORD,
    role: process.env.SF_ROLE
});

connection.connect((err) => {
    if (err) {
        console.error(`Unable to connect: ${err.message}`);
    }
});

function runQuery (query) {
    connection.execute({
        sqlText: query,
        complete: (err, stmt, rows) => {
            if (err) {
                console.log(err.message);
            }
        }
    });
}

function apply_replacements (text) {
    if (process.env.REPLACEMENTS) {
        const replacements = process.env.REPLACEMENTS.split(' ');
        for (let replacement of replacements) {
            if (replacement) {
                const pattern = new RegExp(`@@${replacement}@@`, 'g');
                text = text.replace(pattern, process.env[replacement]);
            }
        }
    }
    return text;
}

const query = apply_replacements(process.argv[2]);

runQuery(query);