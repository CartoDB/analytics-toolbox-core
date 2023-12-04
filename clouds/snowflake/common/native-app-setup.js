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

function runSetRelease (err, stmt, rows) {
    // Get the patches for a given version
    patchesArr = rows.filter(obj => obj['version'] === process.env.VERSION.toUpperCase())
    // Get the max patch number for a given version
    maxPatch = patchesArr.reduce((maxObj, currentObj) => {
        return currentObj['patch'] > maxObj['patch'] ? currentObj : maxObj;
    }, patchesArr[0])['patch']
    const query = `
        ALTER APPLICATION PACKAGE ${process.env.APP_PACKAGE_NAME}
            SET DEFAULT RELEASE DIRECTIVE
            VERSION = ${process.env.VERSION}
            PATCH = ${maxPatch};`
    connection.execute({
        sqlText: query,
        complete: (err, stmt, rows) => {
            if (err) {
                console.log(err.message);
            }
        }
    });
}

function runDropPreviousVersionQuery (err, stmt, rows) {
    // Get the patches different of a given version
    patchesArr = rows.filter(obj => obj['version'] !== process.env.VERSION.toUpperCase())
    if (patchesArr.length >0) {
        // As there can only be two versions we take any patch
        const previousVersion = patchesArr[0]['version']
        const query = `
        ALTER APPLICATION PACKAGE ${process.env.APP_PACKAGE_NAME}
            DROP VERSION ${previousVersion};`
        connection.execute({
            sqlText: query,
            complete: (err, stmt, rows) => {
                if (err) {
                    console.log(err.message);
                }
            }
        });
    }
}


function runGetVersionsQuery (callback) {
    const query = `SHOW VERSIONS IN APPLICATION PACKAGE ${process.env.APP_PACKAGE_NAME};`
    connection.execute({
        sqlText: query,
        complete: callback
    });
}

if (process.env.SET_PACKAGE_RELEASE) {
    runGetVersionsQuery(runSetRelease);
}
else {
    if (process.env.DROP_PREVIOUS_VERSION) {
        runGetVersionsQuery (runDropPreviousVersionQuery)
    }
}
    