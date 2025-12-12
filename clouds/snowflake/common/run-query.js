#!/usr/bin/env node

const crypto = require('crypto');
const snowflake = require('snowflake-sdk');

snowflake.configure({ insecureConnect: true });

// Support both RSA key (CI) and password (local dev) authentication
const connectionOptions = {
    account: process.env.SF_ACCOUNT,
    username: process.env.SF_USER,
    role: process.env.SF_ROLE,
    warehouse: process.env.SF_WAREHOUSE
};

if (process.env.SF_RSA_KEY) {
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
} else {
    connectionOptions.password = process.env.SF_PASSWORD;
}

const connection = snowflake.createConnection(connectionOptions);

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

const query = process.argv[2];

runQuery(query);