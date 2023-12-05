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
    if (patchesArr.length > 0) {
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

function runCheckVersionExistenceQuery (err, stmt, rows) {
    // Get the different patches for a given version
    patchesArr = rows.filter(obj => obj['version'] === process.env.VERSION.toUpperCase())
    if (patchesArr.length > 0) {
        console.log('1')
    } else {
        console.log('0')
    }
}

function runCountVersionsQuery (err, stmt, rows) {
    uniqueVersions = new Set(rows.map(obj => obj['version']))
    console.log(uniqueVersions.size)
}

function runGetVersionsQuery (callback) {
    const query = `SHOW VERSIONS IN APPLICATION PACKAGE ${process.env.APP_PACKAGE_NAME};`
    connection.execute({
        sqlText: query,
        complete: callback
    });
}

function runCheckAppPackageExistenceQuery (err, stmt, rows) {
    packagesArr = rows.filter(obj => obj['name'] === process.env.APP_PACKAGE_NAME.toUpperCase())
    if (packagesArr.length > 0) {
        console.log('1')
    } else {
        console.log('0')
    }
}

function runGetAppPackagesQuery (callback) {
    const query = 'SHOW APPLICATION PACKAGES;'
    connection.execute({
        sqlText: query,
        complete: callback
    });
}
if (process.env.SET_PACKAGE_RELEASE) {
    runGetVersionsQuery(runSetRelease)
} else if (process.env.DROP_PREVIOUS_VERSION) {
    runGetVersionsQuery (runDropPreviousVersionQuery)
} else if (process.env.CHECK_VERSION_EXISTENCE) {
    runGetVersionsQuery (runCheckVersionExistenceQuery)
} else if (process.env.COUNT_VERSIONS) {
    runGetVersionsQuery (runCountVersionsQuery)
} else if (process.env.CHECK_APP_PACKAGE_EXISTENCE) {
    runGetAppPackagesQuery(runCheckAppPackageExistenceQuery)
}